require 'test_helper'

class DomainmetadatumTest < ActiveSupport::TestCase

  def setup
    @domain = Domain.create(name: 'test.org')
    @data = {
      kind: 'ALSO-NOTIFY',
      content: '2.3.4.5',
      domain: @domain
    }
  end


  def teardown
    @domain.destroy
  end


  test "should not save without domain" do
    domainmetadatum = Domainmetadatum.new @data.reject {|k,v| k == :domain}
    assert_not domainmetadatum.save
    assert_equal [:domain_id], domainmetadatum.errors.messages.keys 
  end


  test "should not save without kind" do
    domainmetadatum = Domainmetadatum.new @data.reject {|k,v| k == :kind}
    assert_not domainmetadatum.save
    assert_equal [:kind], domainmetadatum.errors.messages.keys 
  end


  test "should validate content if is soa-edit" do
    domainmetadatum = Domainmetadatum.new @data.merge(kind: 'SOA-EDIT')
    assert_not domainmetadatum.save
    assert_equal [:content], domainmetadatum.errors.messages.keys 
  end

end
