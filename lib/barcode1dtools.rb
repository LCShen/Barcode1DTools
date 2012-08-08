# Copyright 2012 Michael Chaney Consulting Corporation

# encoding: utf-8

$:.unshift(File.dirname(__FILE__))

module Barcode1DTools
  #= barcode1dtools.rb
  #
  # Barcode1DTools is a library for generating 1-dimensional
  # barcode patterns for various code types.  The library
  # currently includes EAN-13 and Interleaved 2 of 5 (I 2/5),
  # but will be expanded to include most 1D barcode types in
  # the near future.
  #
  #== Example
  #  ean13 = Barcode1DTools::EAN13.new('0012676510226', :line_character => 'x', :space_character => ' ')
  #  => #<Barcode1DTools::EAN13:0x10030d670 @check_digit=10, @manufacturers_code="12676", @encoded_string="001267651022610", @number_system="00", @value="0012676510226", @product_code="51022", @options={:line_character=>"1", :space_character=>"0"}>
  #  ean13.bars
  #  "x x   xx x  xx  x  x  xx x xxxx xxx xx x xxxx x x x  xxx xx  xx xxx  x xx xx  xx xx  x x    x x"
  #  ean13.rle
  #  "11132112221212211141312111411111123122213211212221221114111"
  #
  #== Standard Options
  #  When creating a barcode, there are a number of options available:
  #
  #  1. checksum_included - The checksum is included in the value
  #     and does not need to be generated.  This checksum will be
  #     validated and an error raised if it is not proper.
  #  2. skip_checksum - Do not include a checksum if it is optional.
  #     This option is not applicable to most barcode types and
  #     will be ignored unless it is applicable.
  #  3. line_character, space_character - when generating a bar
  #     pattern, determines the characters which will represent bars
  #     and spaces in the pattern.  These default to "1" for lines and
  #     "0" for spaces.
  #  4. w_character, n_character - When generating a w/n pattern,
  #     determines the characters to be used for wide and narrow
  #     bars and spaces.  Defaults to "w" and "n".  Not applicable to
  #     all barcode types.
  #
  #== Standard Object Accessors
  #  1. Barcode1D#value - The actual value of the payload.  If there
  #     is a checksum, it is not part of the value.  This may be a
  #     string or an integer depending on the type of barcode.
  #  2. Barcode1D#check_digit - The checksum digit (or digits).
  #     This is an integer.
  #  3. Barcode1D#encoded_string - The entire literal value that is
  #     encoded, including check digit(s).
  #  4. Barcode1D#options - The options passed to the initializer.


  # Errors for barcodes
  class Barcode1DError < StandardError; end
  class UnencodableError < Barcode1DError; end
  class ValueTooLongError < UnencodableError; end
  class ValueTooShortError < UnencodableError; end
  class UnencodableCharactersError < UnencodableError; end
  class ChecksumError < Barcode1DError; end
  class NotImplementedError < Barcode1DError; end

  class Barcode1D

    attr_reader :check_digit
    attr_reader :value
    attr_reader :encoded_string
    attr_reader :options

    class << self

      # Generate bar pattern string from rle string
      def rle_to_bars(rle_str, options)
        str=0
        rle_str.split('').inject('') { |a,c| str = 1 - str; a + (str.to_s * c.to_i) }.tr('01', options[:space_character].to_s + options[:line_character].to_s)
      end

    end
  end
end

require 'barcode1dtools/interleaved2of5'
require 'barcode1dtools/ean13'