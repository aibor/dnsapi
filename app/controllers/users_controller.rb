class UsersController < ApplicationController

  # GET /users
  # GET /users.json
  def index
    raise User::NotAuthorized unless @current_user.admin
    @users = User.order(:username)
  end


  # GET /users/1
  # GET /users/1.json
  def show
  end


  # GET /users/new
  def new
    @user = User.new(admin: false)
  end


  # GET /users/1/edit
  def edit
  end

  #
  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: t('.success') }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: {error: {status: 422, message: @user.errors}}, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: t('.success') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: {error: {status: 422, message: @user.errors}}, status: :unprocessable_entity }
      end
    end
  end


  def delete
    raise User::NotAuthorized unless @current_user.admin
  end


  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    raise User::NotAuthorized unless @current_user.admin
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path }
      format.json { head :no_content }
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :username, :admin, :password, :password_confirmation,
      :default_primary, :default_postmaster
    )
  end
end
