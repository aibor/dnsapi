class DomainsController < ApplicationController

  # GET /domains
  # GET /domains.json
  def index
    domains = @current_user.admin ? Domain : @current_user.domains
    @domains = domains.includes(:records, :cryptokeys, :users).order(:name)
    @record_count = Record.group(:domain_id).count
  end


  # GET /domains/1
  # GET /domains/1.json
  def show
    per_page = (session[:records_per_page] || 25).to_i
    @records = records_hash(@domain.records.type_sort,
                            per_page < 10 ? 10 : per_page)
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
        unless @domain.users.include? @current_user
          @domain.users << @current_user
        end

        if @domain.create_soa[/1/] && !@domain.soa
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
        if @domain.create_soa[/1/] && !@domain.soa
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
    @records = records_hash(@domain.records.type_sort)
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

  # Build hash, which can be used by records/records partial
  def records_hash(records, per_page = 25)
    count = @domain.records.count
    max_page = (count / per_page) + 1
    page = params[:records_page].to_i
    page = 1 if !page || page == 0
    page = max_page if page > max_page

    {
      page:     page,
      per_page: per_page,
      count:    count,
      records:  records.offset(page.pred * per_page).limit(per_page)
    }
  end

end
