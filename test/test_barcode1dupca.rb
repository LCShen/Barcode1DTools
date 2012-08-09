require 'test/unit'
require 'barcode1dtools'

class Barcode1DToolsUPC_ATest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_checksum_generation
    assert_equal 7, Barcode1DTools::UPC_A.generate_check_digit_for('07820601001')
  end

  def test_checksum_validation
    assert Barcode1DTools::UPC_A.validate_check_digit_for('884088516338')
  end

  def test_attr_readers
    upc_a = Barcode1DTools::UPC_A.new('88408851633', :checksum_included => false)
    assert_equal 8, upc_a.check_digit
    assert_equal '88408851633', upc_a.value
    assert_equal '884088516338', upc_a.encoded_string
    assert_equal '8', upc_a.number_system
    assert_equal '84088', upc_a.manufacturers_code
    assert_equal '51633', upc_a.product_code
  end

  def test_value_fixup
    upc_a = Barcode1DTools::UPC_A.new('88408851633', :checksum_included => false)
    assert_equal 8, upc_a.check_digit
    assert_equal '88408851633', upc_a.value
    assert_equal '884088516338', upc_a.encoded_string
  end

  def test_checksum_error
    # proper checksum is 8
    assert_raise(Barcode1DTools::ChecksumError) { Barcode1DTools::UPC_A.new('884088516331', :checksum_included => true) }
  end

  def test_value_length_errors
    # One digit too short
    assert_raise(Barcode1DTools::UnencodableCharactersError) { Barcode1DTools::UPC_A.new('0123456789', :checksum_included => false) }
    assert_raise(Barcode1DTools::UnencodableCharactersError) { Barcode1DTools::UPC_A.new('01234567890', :checksum_included => true) }
    # One digit too long
    assert_raise(Barcode1DTools::UnencodableCharactersError) { Barcode1DTools::UPC_A.new('012345678901', :checksum_included => false) }
    assert_raise(Barcode1DTools::UnencodableCharactersError) { Barcode1DTools::UPC_A.new('0123456789012', :checksum_included => true) }
  end

  def test_bad_character_errors
    # Characters that cannot be encoded
    assert_raise(Barcode1DTools::UnencodableCharactersError) { Barcode1DTools::UPC_A.new('thisisnotgood', :checksum_included => false) }
  end

  def test_width
    upc_a = Barcode1DTools::UPC_A.new('041343005796', :checksum_included => true)
    assert_equal 95, upc_a.width
  end

  def test_barcode_generation
    upc_a = Barcode1DTools::UPC_A.new('012676510226', :checksum_included => true)
    assert_equal "10100011010011001001001101011110111011010111101010100111011001101110010110110011011001010000101", upc_a.bars
    assert_equal "11132112221212211141312111411111123122213211212221221114111", upc_a.rle
  end

  def test_wn_raises_error
    upc_a = Barcode1DTools::UPC_A.new('012676510226', :checksum_included => true)
    assert_raise(Barcode1DTools::NotImplementedError) { upc_a.wn }
  end
end
