class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from User::NotAuthorized, with: :not_authorized

  skip_before_action :verify_authenticity_token, if: :json_request?

  before_filter :http_basic_authentication

  before_action :set_locale
  before_action :set_object_if_permitted
  before_action :set_nav_controller



  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end


  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }
  end


  def logout
    session[:logout] = true
    redirect_to :root
  end


  protected

  def json_request?
    request.format.json?
  end


  private

  def set_nav_controller
    @nav_controller = %w(domains)
    @nav_controller.insert(0, 'users') if @user and @user.admin
  end


  def record_not_found
    respond_to do |format|
      format.html { raise ActionController::RoutingError.new('Not Found') }
      format.json do
        render json: {error: {status: 404, message: "Not found"}},
          status: :not_found
      end
    end
  end


  def not_authorized
    respond_to do |format|
      format.html do
        flash[:error] = "No permission to this resource."
        redirect_to request.env['HTTP_REFERER'] ? :back : "/#{I18n.locale}"
      end
      format.json do
        render json: {error: {status: 401, message: "Not authorized"}}, 
          status: :unauthorized
      end
    end
  end

  def http_basic_authentication
    realm = Rails.application.class.parent_name + '  Realm'
    authenticate_or_request_with_http_basic realm do |username, password|
      if not session[:logout] and
        @user = User.where(username: username).first
        @user and @user.respond_to?("authenticate")
        !!@user.authenticate(password)
      else
        session[:logout] = nil
      end
    end
  end


  def set_object_if_permitted
    if params[:id] or params[:domain_id]
      model_name = self.class.name.sub(/Controller$/,'').singularize
      resource_name = model_name.downcase
      resource_symbol = resource_name.to_sym

      object = class_eval(model_name).find(params[:id]) if params[:id]
      @domain = if params[:domain_id]
                  Domain.find(params[:domain_id])
                elsif params[resource_symbol] and params[resource_symbol][:domain_id]
                  Domain.find(params[resource_symbol][:domain_id])
                end

      if (object.respond_to?(:users) and object.users.exclude? @user) or
        (object.is_a? User and object != @user) or
        (@domain and @domain.users.exclude? @user)
        raise User::NotAuthorized unless @user.admin
      end
      instance_variable_set('@' + resource_name, object)
    end
  end


  ActionController::Renderers.add :json do |json, options|
    unless json.kind_of?(String)
      json = json.as_json(options) if json.respond_to?(:as_json)
      json = JSON.pretty_generate(json, options)
    end

    if options[:callback].present?
      self.content_type ||= Mime::JS
      "#{options[:callback]}(#{json})"
    else
      self.content_type ||= Mime::JSON
      json
    end
  end
end
