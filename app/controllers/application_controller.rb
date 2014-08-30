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
    @nav_controller.insert(0, 'users') if @current_user and @current_user.admin
  end


  def set_domain(resource_symbol)
    domain_id = if params[resource_symbol]
                  params[resource_symbol][:domain_id]
                else
                  params[:domain_id]
                end

    @domain = Domain.find(domain_id) if domain_id
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
      if not session[:logout] and @current_user = User.find_by(username: username)
        !!@current_user.authenticate(password)
      else
        session[:logout] = nil
      end
    end
  end


  def set_object_if_permitted
    if params[:id] or params[:domain_id]
      model_name = self.class.name.sub(/Controller$/,'').singularize
      resource_name = model_name.downcase

      object = class_eval(model_name).find(params[:id]) if params[:id]

      set_domain(resource_name.to_sym)

      if (object.respond_to?(:users) and object.users.exclude? @current_user) or
        (object.is_a? User and object != @current_user) or
        (@domain and @domain.users.exclude? @current_user)
        raise User::NotAuthorized unless @current_user.admin
      end

      instance_variable_set('@' + resource_name, object)
    end
  end


  def unprocessable_entity_json_hash(object)
    message = object.respond_to?('errors') ? object.errors : ''

    {
      json: {
        error: {
          status: 422,
          message: message
        }
      },
      status: :unprocessable_entity
    }
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
