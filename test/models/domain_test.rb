require 'test_helper'

class DomainTest < ActiveSupport::TestCase

  test "should not save without name" do
    domain = Domain.new(type: 'MASTER')
    assert_not domain.save
  end


  test "name must be valid domain name" do
    domain = Domain.new(name: 'foa-', type: 'MASTER')
    assert_not domain.save
  end


  test "should set default type if no type given" do
    domain = Domain.new(name: 'foo.com')
    assert domain.save
    assert_equal 'MASTER', domain.type
  end


  test "should remove trailing dot in name" do
    domain = Domain.new(name: 'foo.com.')
    assert domain.save
    assert_equal 'foo.com', domain.name
  end


  test "should create default SOA record" do
    domain = Domain.new(name: 'foo.com.')
    assert domain.save
    assert_not domain.soa
    domain.create_default_soa(users(:user))
    assert domain.soa
  end

end
