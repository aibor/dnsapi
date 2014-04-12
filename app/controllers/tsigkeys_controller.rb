class TsigkeysController < ApplicationController
  before_action :set_tsigkey, only: [:show, :edit, :update, :destroy]

  # GET /tsigkeys
  # GET /tsigkeys.json
  def index
    @tsigkeys = Tsigkey.all
  end

  # GET /tsigkeys/1
  # GET /tsigkeys/1.json
  def show
  end

  # GET /tsigkeys/new
  def new
    @tsigkey = Tsigkey.new
  end

  # GET /tsigkeys/1/edit
  def edit
  end

  # POST /tsigkeys
  # POST /tsigkeys.json
  def create
    @tsigkey = Tsigkey.new(tsigkey_params)

    respond_to do |format|
      if @tsigkey.save
        format.html { redirect_to @tsigkey, notice: 'Tsigkey was successfully created.' }
        format.json { render :show, status: :created, location: @tsigkey }
      else
        format.html { render :new }
        format.json { render json: @tsigkey.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tsigkeys/1
  # PATCH/PUT /tsigkeys/1.json
  def update
    respond_to do |format|
      if @tsigkey.update(tsigkey_params)
        format.html { redirect_to @tsigkey, notice: 'Tsigkey was successfully updated.' }
        format.json { render :show, status: :ok, location: @tsigkey }
      else
        format.html { render :edit }
        format.json { render json: @tsigkey.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tsigkeys/1
  # DELETE /tsigkeys/1.json
  def destroy
    @tsigkey.destroy
    respond_to do |format|
      format.html { redirect_to tsigkeys_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tsigkey
      @tsigkey = Tsigkey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tsigkey_params
      params.require(:tsigkey).permit(:name, :algorithm, :secret)
    end
end
