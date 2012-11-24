class UsersController < ApplicationController
  def index
    render :text => "Wrong place to be..."
  end
  
  def show
    @user = User.find(params[:id])
    @posts = Post.by_user(@user)
    respond_to do |format|
      format.html
    end
  end
end