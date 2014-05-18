class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :json_request?

  before_action :set_locale
  before_filter :basic_http_authentication

  def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
      logger.debug "default_url_options is passed options: #{options.inspect}\n"
        { locale: I18n.locale }
  end

  protected

  def json_request?
    request.format.json?
  end

  private

  def basic_http_authentication
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        username == 'op' && password == 'german+english=AC3WTFsquared'
      end
    end
  end
end
