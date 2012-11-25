class UsersController < ApplicationController
  def index
    render :text => "Wrong place to be..."
  end
  
  def show
    @user = User.find(params[:id])
    @posts = Post.by_user(@user)
    render :text => "User has no post" and return if @posts.blank?
    @user_owns_page = (@user.id == current_user.id)
    respond_to do |format|
      format.html
    end
  end
end