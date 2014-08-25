class DomainsController < ApplicationController

  # GET /domains
  # GET /domains.json
  def index
    domains = if @current_user.admin
                 Domain
               else
                 @current_user.domains
               end
    @domains = domains.includes(:records, :cryptokeys, :users).order(:name)
  end


  # GET /domains/1
  # GET /domains/1.json
  def show
    @records_page = params[:records_page].to_i
  end


  # GET /domains/new
  def new
    @domain = Domain.new
  end


  def secure
    respond_to do |format|
      if @domain.secure_zone
        format.html { redirect_to :back, notice: t('.success') }
        format.json { render :show, status: :created, location: @domain }
      else
        format.html { redirect_to :back }
        format.json { render unprocessable_entity_json_hash(@domain) }
      end
    end
  end


  # GET /domains/1/edit
  def edit
  end


  # POST /domains
  # POST /domains.json
  def create
    @domain = Domain.new(domain_params)

    respond_to do |format|
      if @domain.save
        @domain.users << @current_user

        if @domain.create_soa and not @domain.soa
          @domain.create_default_soa @current_user
        end

        format.html { redirect_to @domain, notice: t('.success') }
        format.json { render :show, status: :created, location: @domain }
      else
        format.html { render :new }
        format.json { render unprocessable_entity_json_hash(@domain) }
      end
    end
  end


  def import_zone
  end


  def parse_zone
    respond_to do |format|
      if @domain.import_zone_file(params[:zone_file])
        format.html { redirect_to @domain, notice: t('.success') }
        format.json { render :show, status: :created, location: @domain }
      else
        format.html { render :import_zone, locals: {params: params} }
        format.json { render unprocessable_entity_json_hash(@domain) }
      end
    end
  end


  # PATCH/PUT /domains/1
  # PATCH/PUT /domains/1.json
  def update
    respond_to do |format|
      if @domain.update(domain_params)
        if @domain.create_soa and not @domain.soa
          @domain.create_default_soa @current_user
        end

        format.html { redirect_to @domain, notice: t('.success') }
        format.json { render :show, status: :ok, location: @domain }
      else
        format.html { render :edit }
        format.json { render unprocessable_entity_json_hash(@domain) }
      end
    end
  end


  def delete
    @records_page = params[:records_page].to_i
  end


  # DELETE /domains/1
  # DELETE /domains/1.json
  def destroy
    @domain.destroy
    respond_to do |format|
      format.html { redirect_to domains_url }
      format.json { head :no_content }
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def domain_params
    params.require(:domain).permit(
      :name, :master, :last_check, :type, :notified_serial, :account,
      :create_soa, user_ids: []
    )
  end
end
