class CommentsController < ApplicationController

  # GET /comments
  # GET /comments.json
  def index
    @comments = if @domain
                  @domain.comments
                elsif @user.admin
                  Comment.all
                else
                  @user.comments
                end
  end


  # GET /comments/1
  # GET /comments/1.json
  def show
  end


  # GET /comments/new
  def new
    @comment = Comment.new(domain: @domain)
  end


  # GET /comments/1/edit
  def edit
  end


  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @comment, notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new }
        format.json { render json: {error: {status: 422, message: @comment.errors}}, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: {error: {status: 422, message: @comment.errors}}, status: :unprocessable_entity }
      end
    end
  end


  def delete
  end


  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    domain = @comment.domain
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to domain }
      format.json { head :no_content }
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:domain_id, :name, :type, :modified_at, :account, :comment)
  end
end
