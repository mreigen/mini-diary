class UsersController < ApplicationController
  def index
    render :text => "Wrong place to be..."
  end
  
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end