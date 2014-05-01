class DomainmetadataController < ApplicationController
  before_action :set_domainmetadatum, only: [:show, :edit, :update, :destroy, :delete]

  # GET /domainmetadata
  # GET /domainmetadata.json
  def index
    @domainmetadata = Domainmetadatum.all
  end

  # GET /domainmetadata/1
  # GET /domainmetadata/1.json
  def show
  end

  # GET /domainmetadata/new
  def new
    @domain = Domain.find(params[:domain_id]) rescue nil
    @domainmetadatum = Domainmetadatum.new(domain: @domain)
  end

  # GET /domainmetadata/1/edit
  def edit
  end

  # POST /domainmetadata
  # POST /domainmetadata.json
  def create
    @domainmetadatum = Domainmetadatum.new(domainmetadatum_params)

    respond_to do |format|
      if @domainmetadatum.save
        format.html { redirect_to @domainmetadatum, notice: 'Domainmetadatum was successfully created.' }
        format.json { render :show, status: :created, location: @domainmetadatum }
      else
        format.html { render :new }
        format.json { render json: @domainmetadatum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /domainmetadata/1
  # PATCH/PUT /domainmetadata/1.json
  def update
    respond_to do |format|
      if @domainmetadatum.update(domainmetadatum_params)
        format.html { redirect_to @domainmetadatum, notice: 'Domainmetadatum was successfully updated.' }
        format.json { render :show, status: :ok, location: @domainmetadatum }
      else
        format.html { render :edit }
        format.json { render json: @domainmetadatum.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete
  end

  # DELETE /domainmetadata/1
  # DELETE /domainmetadata/1.json
  def destroy
    @domainmetadatum.destroy
    respond_to do |format|
      format.html { redirect_to domainmetadata_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domainmetadatum
      @domainmetadatum = Domainmetadatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def domainmetadatum_params
      params.require(:domainmetadatum).permit(:domain_id, :kind, :content)
    end
end
