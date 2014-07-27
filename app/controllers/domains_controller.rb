class DomainsController < ApplicationController

  # GET /domains
  # GET /domains.json
  def index
    @domains = if @user.admin 
                 Domain.order(:name)
               else
                 @user.domains.order(:name)
               end
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
        format.json { render json: @domain.errors, status: :unprocessable_entity }
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
        @domain.users << @user
        @domain.create_default_soa @user
        format.html { redirect_to @domain, notice: t('.success') }
        format.json { render :show, status: :created, location: @domain }
      else
        format.html { render :new }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /domains/1
  # PATCH/PUT /domains/1.json
  def update
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to @domain, notice: t('.success') }
        format.json { render :show, status: :ok, location: @domain }
      else
        format.html { render :edit }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
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
      :name, :master, :last_check, :type, :notified_serial, :account, user_ids: []
    )
  end
end
