require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test 'should receive unauthorized' do
    get :index
    assert_response :unauthorized
  end


  test 'user should get own users page' do
    auth_as :user
    get :show, id: users(:user).id
    assert_response :success
  end


  test 'user should not get other users page' do
    auth_as :user
    get :show, id: users(:admin).id
    assert_redirected_to '/de'
  end


  test 'admin should get other users page' do
    auth_as :admin
    get :show, id: users(:user).id
    assert_response :success
  end

end
