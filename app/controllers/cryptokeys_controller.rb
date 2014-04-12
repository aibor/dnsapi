class CryptokeysController < ApplicationController
  before_action :set_cryptokey, only: [:show, :edit, :update, :destroy]

  # GET /cryptokeys
  # GET /cryptokeys.json
  def index
    @cryptokeys = Cryptokey.all
  end

  # GET /cryptokeys/1
  # GET /cryptokeys/1.json
  def show
  end

  # GET /cryptokeys/new
  def new
    @domain = Domain.find(params[:domain_id]) rescue nil
    @cryptokey = Cryptokey.new(domain: @domain)
  end

  # GET /cryptokeys/1/edit
  def edit
  end

  # POST /cryptokeys
  # POST /cryptokeys.json
  def create
    @cryptokey = Cryptokey.new(cryptokey_params)

    respond_to do |format|
      if @cryptokey.save
        format.html { redirect_to @cryptokey, notice: 'Cryptokey was successfully created.' }
        format.json { render :show, status: :created, location: @cryptokey }
      else
        format.html { render :new }
        format.json { render json: @cryptokey.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cryptokeys/1
  # PATCH/PUT /cryptokeys/1.json
  def update
    respond_to do |format|
      if @cryptokey.update(cryptokey_params)
        format.html { redirect_to @cryptokey, notice: 'Cryptokey was successfully updated.' }
        format.json { render :show, status: :ok, location: @cryptokey }
      else
        format.html { render :edit }
        format.json { render json: @cryptokey.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cryptokeys/1
  # DELETE /cryptokeys/1.json
  def destroy
    @cryptokey.destroy
    respond_to do |format|
      format.html { redirect_to cryptokeys_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cryptokey
      @cryptokey = Cryptokey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cryptokey_params
      params.require(:cryptokey).permit(:domain_id, :flags, :active, :content)
    end
end
