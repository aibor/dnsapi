class DomainmetadataController < ApplicationController

  # GET /domainmetadata
  # GET /domainmetadata.json
  def index
    @domainmetadatas = if @domain
                         @domain.domainmetadata
                       elsif @current_user.admin
                         Domainmetadatum.all
                       else
                         @current_user.domainmetadata
                       end
  end


  # GET /domainmetadata/1
  # GET /domainmetadata/1.json
  def show
  end


  # GET /domainmetadata/new
  def new
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
        format.json { render json: {error: {status: 422, message: @domainmetadatum.errors}}, status: :unprocessable_entity }
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
        format.json { render json: {error: {status: 422, message: @domainmetadatum.errors}}, status: :unprocessable_entity }
      end
    end
  end


  def delete
  end


  # DELETE /domainmetadata/1
  # DELETE /domainmetadata/1.json
  def destroy
    domain = @domainmetadatum.domain
    @domainmetadatum.destroy
    respond_to do |format|
      format.html { redirect_to domain }
      format.json { head :no_content }
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def domainmetadatum_params
    params.require(:domainmetadatum).permit(:domain_id, :kind, :content)
  end
end
