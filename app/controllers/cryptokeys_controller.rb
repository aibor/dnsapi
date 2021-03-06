class CryptokeysController < ApplicationController
  #
  # GET /cryptokeys
  # GET /cryptokeys.json
  def index
    @cryptokeys = if @domain
                    @domain.cryptokeys
                  elsif @current_user.admin
                    Cryptokey.all
                  else
                    @current_user.cryptokeys
                  end
  end


  # GET /cryptokeys/1
  # GET /cryptokeys/1.json
  def show
  end


  # GET /cryptokeys/new
  def new
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
        format.html { redirect_to @cryptokey,
                      notice: 'Cryptokey was successfully created.' }
        format.json { render :show, status: :created, location: @cryptokey }
      else
        format.html { render :new }
        format.json { render unprocessable_entity_json_hash(@cryptokey) }
      end
    end
  end


  # PATCH/PUT /cryptokeys/1
  # PATCH/PUT /cryptokeys/1.json
  def update
    respond_to do |format|
      if @cryptokey.update(cryptokey_params)
        format.html { redirect_to @cryptokey,
                      notice: 'Cryptokey was successfully updated.' }
        format.json { render :show, status: :ok, location: @cryptokey }
      else
        format.html { render :edit }
        format.json { render unprocessable_entity_json_hash(@cryptokey) }
      end
    end
  end


  def delete
  end


  # DELETE /cryptokeys/1
  # DELETE /cryptokeys/1.json
  def destroy
    domain = @cryptokey.domain
    @cryptokey.destroy
    respond_to do |format|
      format.html { redirect_to domain }
      format.json { head :no_content }
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def cryptokey_params
    params.require(:cryptokey).permit(:domain_id, :flags, :active, :content)
  end
end
