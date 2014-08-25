require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  def setup
    @domain = Domain.create(name: 'test.org')
    @record_data = {
      name: 'test.org.',
      type: 'A',
      ttl: 86400,
      content: '2.3.4.5',
      domain: @domain
    }
  end


  def teardown
    @domain.destroy
  end


  test "should set default name if no name given" do
    record = Record.new @record_data.reject {|k,v| k == :name}
    assert record.save
    assert_equal @domain.name, record.name
  end


  test "should remove trailing dot in name" do
    record = Record.new @record_data
    assert record.save
    assert_equal 'test.org', record.name
  end


  test "should set default TTL" do
    record = Record.new @record_data.reject {|k,v| k == :ttl}
    assert record.save
    assert_equal 86400, record.ttl
  end


  test "should not save without domain" do
    record = Record.new @record_data.reject {|k,v| k == :domain}
    assert_not record.save
    assert_equal [:domain_id], record.errors.messages.keys 
  end


  test "should not save without type" do
    record = Record.new @record_data.reject {|k,v| k == :type}
    assert_not record.save
    assert_equal [:type], record.errors.messages.keys 
  end


  test "should not save with unknown type" do
    record = Record.new @record_data.merge(type: 'AWESOME')
    assert_not record.save
    assert_equal [:type], record.errors.messages.keys 
  end


  test "should only save unique records" do
    record = Record.new @record_data
    assert record.save
    record = Record.new @record_data
    assert_not record.save
    assert_equal [:base], record.errors.messages.keys 
  end


  test "should not save invalid record" do
    record = Record.new @record_data.merge(content: '2.3.4.5.6')
    assert_not record.save
    assert_equal [:content], record.errors.messages.keys 
  end


  test "should generate token" do
    record = Record.first
    assert_difference(record.token, 64) {record.generate_token}
  end


  test "should sort in useful order" do
    records = Record.all.type_sort.map {|r| [r.type, r.name]}

    expected_order = [
      %w(SOA example.com),
      %w(SOA test.de),
      %w(MX example.com),
      %w(MX test.de),
      %w(A example.com),
      %w(A mail.example.com),
      %w(A mail.test.de),
      %w(A test.de)
    ]

    assert_equal expected_order, records
  end
    
end
