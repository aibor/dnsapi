class RecordsController < ApplicationController
  skip_before_filter :http_basic_authentication,
    :set_object_if_permitted,
    only: [:tokenized_update]

  # GET /records
  # GET /records.json
  def index
    @records = if @domain
                 @domain.records
               elsif @current_user.admin
                 Record.all
               else
                 @current_user.records
               end
  end


  # GET /records/1
  # GET /records/1.json
  def show
  end


  # GET /records/new
  def new
    @record = Record.new(domain: @domain)
  end


  # GET /records/1/edit
  def edit
  end


  # GET /records/1/clone
  def clone
    @record = Record.new(@record.attributes.reject {|k,v| k =~ /\A(?:id|change_date)\z/})
    render :new
  end


  # POST /records
  # POST /records.json
  def create
    @record = Record.new(record_params)

    respond_to do |format|
      if @record.save
        no_validator = @record.has_dns_validator? ? nil : t('.no_validator')
        no_validator ||= t('.no_type_validation') unless @record.no_type_validation.to_i.zero?
        format.html { redirect_to @record, notice: t('.success'), alert: no_validator }
        format.json { render :show, status: :created, location: @record }
      else
        format.html { render :new }
        format.json { render json: {error: {status: 422, message: @record.errors}}, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /records/1
  # PATCH/PUT /records/1.json
  def update
    respond_to do |format|
      if @record.update(record_params)
        no_validator = @record.has_dns_validator? ? nil : t('.no_validator')
        no_validator ||= t('.no_type_validation') unless @record.no_type_validation.to_i.zero?
        format.html { redirect_to @record, notice: t('.success'), alert: no_validator }
        format.json { render :show, status: :ok, location: @record }
      else
        format.html { render :edit }
        format.json { render json: {error: {status: 422, message: @record.errors}}, status: :unprocessable_entity }
      end
    end
  end


  def generate_token
    @record.generate_token

    respond_to do |format|
      if @record.save
        format.html { redirect_to @record, notice: t('.success') }
        format.json { render :show, status: :ok, location: @record }
      else
        format.html { redirect_to @record, error: t('.error') }
        format.json { render json: {error: {status: 422, message: @record.errors}}, status: :unprocessable_entity }
      end
    end
  end


  def tokenized_update
    @record = Record.find(params[:id])
    content = params[:content]
    content ||= request.remote_ip if %w(A AAAA).include? @record.type

    if token_valid? and @record.update_attributes(content: content)
      render :show, status: :ok, location: @record
    else
      render json: {error: {status: 422, message: @record.errors}}, status: :unprocessable_entity
    end
  end


  def delete
  end


  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    domain = @record.domain
    @record.destroy
    respond_to do |format|
      format.html { redirect_to domain }
      format.json { head :no_content }
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def record_params
    params.require(:record).permit(
      :domain_id, :name, :type, :content, :ttl, :prio, :ordername, :auth,
      :change_date, :disabled, :token, :no_type_validation
    )
  end


  def token_valid?
    bool = (params[:token] and
            not @record.token.blank? and
            params[:token] == @record.token)

    unless bool 
      @record.errors.add(:records, 'Go away!')
    end

    bool
  end
end
