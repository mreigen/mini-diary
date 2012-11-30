class UsersController < ApplicationController
  def index
    render :text => "Wrong place to be..."
  end
  
  def show
    @page_size = 4
    @user = User.find(params[:id])
    @posts = Post.by_user_id(@user.id).first(@page_size)
    render :text => "User has no post" and return if @posts.blank?
    @user_owns_page = !current_user.blank? && @user.id == current_user.id
    respond_to do |format|
      format.html
    end
  end
end