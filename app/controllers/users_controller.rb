class UsersController < ApplicationController

  before_filter :admin_only, except: [:show, :edit, :update]

  # GET /users
  # GET /users.json
  def index
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
        format.json { render unprocessable_entity_json_hash(@user) }
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
        format.json { render unprocessable_entity_json_hash(@user) }
      end
    end
  end


  def delete
  end


  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
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


  def admin_only
    raise User::NotAuthorized unless @current_user.admin
  end

end
