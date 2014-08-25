ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

 
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
 
  # Add more helper methods to be used by all tests here...

  def set_auth_env(user, password)
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(
      user, password
    ) 
  end


  def auth_as(type)
    credentials = case type
                  when :user then  ['bob', 'qwertzuiasdfghjk']
                  when :admin then ['oper', 'asdfghjk12345678']
                  end

    set_auth_env *credentials
  end
end

class ActionDispatch::IntegrationTest
  fixtures :all
end
