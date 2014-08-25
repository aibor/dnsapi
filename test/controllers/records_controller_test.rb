require 'test_helper'

class RecordsControllerTest < ActionController::TestCase

  test 'should receive unauthorized' do
    get :show, id: users(:user).domains.first.records.first.id
    assert_response :unauthorized
  end


  test 'user should get own records page' do
    auth_as :user
    get :show, id: users(:user).domains.first.records.first.id
    assert_response :success
  end


  test 'user should not get other users records page' do
    auth_as :user
    get :show, id: users(:admin).domains.first.records.first.id
    assert_redirected_to '/de'
  end


  test 'admin should get other users records page' do
    auth_as :admin
    get :show, id: users(:user).domains.first.records.first.id
    assert_response :success
  end


  test 'should have token afterwards' do
    auth_as :user

    record = users(:user).domains.first.records.first 
    put :generate_token, id: record.id

    assert_redirected_to record
    assert_equal 64, Record.find(record.id).token.length
  end


  test 'ddns update via token' do
    new_addr = '12.12.12.12'

    @request.env['REMOTE_ADDR'] = new_addr

    put(
      :tokenized_update,
      id: records(:seven).id,
      token: records(:seven).token,
      format: :json
    )

    assert_response :success
    assert_equal new_addr, Record.find(records(:seven).id).content
  end

end
