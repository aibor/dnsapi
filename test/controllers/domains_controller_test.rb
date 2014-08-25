require 'test_helper'

class DomainsControllerTest < ActionController::TestCase

  test 'should receive unauthorized' do
    get :index
    assert_response :unauthorized
  end


  test 'user should get own domains page' do
    auth_as :user
    get :show, id: users(:user).domains.first.id
    assert_response :success
  end


  test 'user should not get other users domains page' do
    auth_as :user
    get :show, id: users(:admin).domains.first.id
    assert_redirected_to '/de'
  end


  test 'admin should get other users domains page' do
    auth_as :admin
    get :show, id: users(:user).domains.first.id
    assert_response :success
  end

end
