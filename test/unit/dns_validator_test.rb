require 'test_helper'


class DNSValidatorTest < ActiveSupport::TestCase

  def setup
    @domain = Domain.create(name: 'test.org')
    @record = Record.new(
      name: 'test.org.',
      type: 'A',
      ttl: 86400,
      content: '2.3.4.5',
      domain: @domain
    )
  end


  def teardown
    @domain.destroy
  end


  test "should be valid A resource record" do
    valid_type_check
  end


  test "should be invalid A resource record" do
    @record.content = '2.3.4.256'
    invalid_type_check
  end


  test "should be valid AAAA resource record" do
    @record.type = 'AAAA'
    @record.content = '2:3::1'
    valid_type_check
  end


  test "should be invalid AAAA resource record" do
    @record.type = 'AAAA'
    @record.content = '2:3:g:1'
    invalid_type_check
  end


  test "should be valid CNAME resource record" do
    @record.type = 'CNAME'
    @record.content = 'ns.test.org'
    valid_type_check
  end


  test "should be invalid CNAME resource record" do
    @record.type = 'CNAME'
    invalid_type_check
  end


  test "should be valid HINFO resource record" do
    @record.type = 'HINFO'
    @record.content = '"Awesome Processor SO WOW" "Amazing GNU/Linux"'
    valid_type_check
  end


  test "should be invalid HINFO resource record" do
    @record.type = 'HINFO'
    @record.content = "CPU OS OOPS"
    invalid_type_check
  end


  test "should be valid MINFO resource record" do
    @record.type = 'MINFO'
    @record.content = 'ml.test.org admin.test.org'
    valid_type_check
  end


  test "should be invalid MINFO resource record" do
    @record.type = 'MINFO'
    @record.content = "noooo m00 roar"
    invalid_type_check
  end


  test "should be valid MX resource record" do
    @record.type = 'MX'
    @record.prio = 10
    @record.content = 'mail.test.org'
    valid_type_check
  end


  test "should be invalid MX resource record due to missing prio" do
    @record.type = 'MX'
    @record.content = 'mail.test.org'
    invalid_type_check :prio
  end


  test "should be invalid MX resource record due to missing content" do
    @record.type = 'MX'
    @record.prio = 10
    @record.content = nil
    invalid_type_check
  end


  test "should be invalid MX resource record due to content" do
    @record.type = 'MX'
    @record.prio = 10
    @record.content = "noooo m00"
    invalid_type_check
  end


  test "should be valid NS resource record" do
    @record.type = 'NS'
    @record.content = 'ns.test.org'
    valid_type_check
  end


  test "should be duplicate NS resource record" do
    @record.name = 'test.org'
    @record.type = 'NS'
    @record.content = 'ns.test.org'
    Record.create(@record.attributes.reject {|k,v| v.nil?})
    invalid_type_check :base
  end


  test "should be invalid NS resource record" do
    @record.type = 'NS'
    invalid_type_check
  end


  test "should be valid PTR resource record" do
    @record.type = 'PTR'
    @record.content = '42.0.0.10.in-addr.arpa.'
    valid_type_check
  end


  test "should be invalid PTR resource record" do
    @record.type = 'PTR'
    @record.content = '.in-addr.arpa.'
    invalid_type_check
  end


  test "should be valid SOA resource record" do
    @record.type = 'SOA'
    @record.content = 'ns.test.org. postmaster.test.org 1234 86400 300 6000000 3600'
    valid_type_check
  end


  test "should be invalid SOA resource record du to missing fields" do
    @record.type = 'SOA'
    @record.content = 'ns.test.org. postmaster.test.org 1234 86400 300 6000000'
    invalid_type_check
  end


  test "should be invalid SOA resource record du to too large field" do
    @record.type = 'SOA'
    @record.content = 'ns.test.org. postmaster.test.org 1234 86400 300 6000000000000000000 3600'
    invalid_type_check
  end


  test "should be invalid SOA resource record du to invalid primary ns" do
    @record.type = 'SOA'
    @record.content = 'test- postmaster.test.org 1234 86400 300 6000000 3600'
    invalid_type_check
  end


  test "should be invalid SOA resource record du to invalid postmaster" do
    @record.type = 'SOA'
    @record.content = 'ns.test.org. test.org 1234 86400 300 6000000 3600'
    invalid_type_check
  end


  test "should be invalid SOA resource record du to zero field" do
    @record.type = 'SOA'
    @record.content = 'ns.test.org. postmaster.test.org 1234 86400 0 6000000 3600'
    invalid_type_check
  end


  test "should be invalid SOA resource record du to non-number field" do
    @record.type = 'SOA'
    @record.content = 'ns.test.org. postmaster.test.org 1234 86400 m00 6000000 3600'
    invalid_type_check
  end


  test "should be valid SSHFP resource record" do
    @record.type = 'SSHFP'
    @record.content = '2 1 123456789abcdef67890123456789abcdef67890'
    valid_type_check
  end


  test "should be invalid SSHFP resource record" do
    @record.type = 'SSHFP'
    @record.content = '2 2 123456789abcdef67890123456789abcdef67890'
    invalid_type_check
  end


  # https://www.aibor.de/redmine/issues/23
  test "should be valid resource name" do
    @record.type = 'TXT'
    @record.name = 'john.doe._domainkey.test.org.'
    valid_type_check
  end


  private

  def valid_type_check
    DNSValidator::ResourceRecord.class_eval(@record.type).new(@record).
      validate
    #puts @record.errors.messages
    assert_equal [], @record.errors.messages.keys 
  end


  def invalid_type_check(key = :content)
    DNSValidator::ResourceRecord.class_eval(@record.type).new(@record).
      validate
    # puts @record.errors.messages
    assert_equal [key], @record.errors.messages.keys 
  end

end
