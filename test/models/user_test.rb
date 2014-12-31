require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "password" do
    assert users(:user).authenticate('qwertzuiasdfghjk')
  end


  test "should not save without username" do
    user = User.new(password: 'what_a_great_pw_this_is')
    refute user.save
  end


  test "should not save without password" do
    user = User.new(username: 'foo')
    refute user.save
  end


  test "password must be long enough" do
    user = User.new(username: 'foo', password: 'oh_too_short')
    refute user.save
  end

end
