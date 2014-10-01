require 'test_helper'

class DdnsTest < ActionDispatch::IntegrationTest

  test 'ddns update via token and PUT verb' do
    new_addr = '12.12.12.12'

    put_via_redirect(
      "/tokenized_update/#{records(:seven).token}",
      nil,
      'REMOTE_ADDR' => new_addr
    )

    assert_response :success
    assert_equal new_addr, Record.find(records(:seven).id).content
  end

  test 'ddns update via token and GET verb' do
    new_addr = '12.12.12.13'

    get_via_redirect(
      "/tokenized_update/#{records(:seven).token}",
      nil,
      'REMOTE_ADDR' => new_addr
    )

    assert_response :success
    assert_equal new_addr, Record.find(records(:seven).id).content
  end
end
