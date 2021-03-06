#--
# Copyright 2012 Michael Chaney Consulting Corporation
#
# Released under the terms of the MIT License or the GNU
# General Public License, v. 2
#++

require 'barcode1dtools/ean13'

module Barcode1DTools

  # Barcode1DTools::UPC_A - Create pattern for UPC-A barcodes.
  # The value encoded is an 11-digit integer, and a checksum digit
  # will be added.  You can add the option :checksum_included => true
  # when initializing to specify that you have already included a
  # checksum.
  #
  # == Example
  #  # Note that this number is a UPC-A, with the number system of 08,
  #  # manufacturer's code of "28999", product code of "00682", and a
  #  # checksum of "3" (not included)
  #  num = '82899900682'
  #  bc = Barcode1DTools::UPC_A.new(num)
  #  pattern = bc.bars
  #  rle_pattern = bc.rle
  #  width = bc.width
  #  check_digit = Barcode1DTools::UPC_A.generate_check_digit_for(num)
  #
  # == Other Information
  # A UPC-A barcode is an EAN-13 with an initial digit of "0" (that
  # is the left digit of the number system designator).  Like the
  # EAN-13, the code is broken into a single-digit number system,
  # 5 digit manufacturer code, 5 digit product code, and single
  # digit checksum.
  #
  # The number system is:
  #  0, 1, 6, 7, 8 - standard UPC codes
  #  2    - a product weight- generally calculated at the store.
  #  3    - pharmaceuticals
  #  4    - used for loyalty cards at stores
  #  5    - coupons
  #  9    - coupons
  #  978  - for books, with a 10-digit ISBN coming after 978
  #
  # For code 2, the manufacturer code becomes an item number, and the
  # product number is used for either the weight or the price, with
  # the first digit determining which.
  #
  # For 5 and 9, the manufacturer code is the same as a standard
  # UPC.  The first three digits of the product code are used as a
  # "family code" set by the manufacturer, and the last two digits
  # are a "coupon code" which determines the amount of the discount
  # based on a table released by the GS1 US (formerly the UCC).
  # Code 5 coupons may be doubled or tripled, but code 9 may not.
  #
  # == Formats
  # There are two formats for the returned pattern (wn format is
  # not available):
  #
  # *bars* - 1s and 0s specifying black lines and white spaces.  Actual
  # characters can be changed from "1" and 0" with options
  # :line_character and :space_character.
  #
  # *rle* - Run-length-encoded version of the pattern.  The first
  # number is always a black line, with subsequent digits
  # alternating between spaces and lines.  The digits specify
  # the width of each line or space.
  #
  # The "width" method will tell you the total end-to-end width, in
  # units, of the entire barcode.
  #
  # Unlike some of the other barcodes, e.g. Code 3 of 9, there is no "w/n" format for
  # EAN & UPC style barcodes because the bars and spaces are variable width from
  # 1 to 4 units.
  # 
  # == Rendering
  #
  # The UPC-A is typically rendered at 1-1.5 inch across, and half
  # an inch high.  The number system digit and checksum digit are
  # shown on the left and right sides of the code.  The other two
  # sets of five digits are rendered at the bottom of the barcode.
  # The alignment can be either bottom of the text flush with
  # bottom of barcode, or middle of text aligned with bottom of
  # barcode.  The two sets of five digits are separated by the two
  # middle guard bars which always extend to the bottom.  There
  # should be at least 9 spaces of quiet area on either side of
  # the code.

  class UPC_A < EAN13

    class << self
      # Returns true or false - must be 11-13 digits.  This
      # also handles the case where the leading 0 is added.
      def can_encode?(value, options = nil)
        if !options
          value.to_s =~ /^0?[0-9]{11,12}$/
        elsif (options[:checksum_included])
          value.to_s =~ /^0?[0-9]{12}$/
        else
          value.to_s =~ /^0?[0-9]{11}$/
        end
      end

      # Generates check digit given a string to encode.  It assumes there
      # is no check digit on the "value".
      def generate_check_digit_for(value)
        super('0' + value)
      end

      # Validates the check digit given a string - assumes check digit
      # is last digit of string.
      def validate_check_digit_for(value)
        raise UnencodableCharactersError unless self.can_encode?(value, :checksum_included => true)
        md = value.match(/^(0?\d{11})(\d)$/)
        self.generate_check_digit_for(md[1]) == md[2].to_i
      end

      # Decode a bar pattern or rle pattern and return a UPC_A object.
      def decode(value)
        ean = super(value)
        if ean.value[0,1] == '0'
          new(ean.value[1,11])
        else
          raise UnencodableCharactersError
        end
      end
    end

    # Create a new UPC_A object with a given value.
    # Options are :line_character, :space_character, and
    # :checksum_included.
    def initialize(value, options = {})

      @options = DEFAULT_OPTIONS.merge(options)

      # Can we encode this value?
      raise UnencodableCharactersError unless self.class.can_encode?(value, @options)

      if @options[:checksum_included]
        @encoded_string = value.to_s
        raise ChecksumError unless self.class.validate_check_digit_for(@encoded_string)
        md = @encoded_string.match(/^(\d+?)(\d)$/)
        @value, @check_digit = md[1], md[2].to_i
      else
        # need to add a checksum
        @value = value.to_s
        @check_digit = self.class.generate_check_digit_for(@value)
        @encoded_string = "#{@value}#{@check_digit}"
      end

      md = @value.match(/^(\d)(\d{5})(\d{5})/)
      @number_system, @manufacturers_code, @product_code = md[1], md[2], md[3]
    end

    # Returns a run-length-encoded string representation.
    def rle
      if @rle
        @rle
      else
        md = @encoded_string.match(/^(\d{6})(\d{6})/)
        @rle = gen_rle('0', md[1], md[2])
      end
    end

    # Returns a UPC_E object with the same value as the
    # current UPC_A object, if possible.
    def to_upc_e
      UPC_E.new(UPC_E.upca_value_to_upce_value(@value), options.merge(:checksum_included => false))
    end

    # Returns true if the current value may be encoded as UPC-E.
    def upc_e_encodable?
      begin
        UPC_E.new(UPC_E.upca_value_to_upce_value(@value), options.merge(:checksum_included => false))
        return true
      rescue UnencodableCharactersError
        return false
      end
    end

  end
end
