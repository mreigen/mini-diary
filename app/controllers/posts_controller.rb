class PostsController < ApplicationController
  
  def new
    
  end
  
  def index
    @posts = Post.last(10).reverse
    respond_to do |format|
      format.html
    end
  end
  
  def show
    @post = Post.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @post }
    end
  end
  
  def create
    render :text => "please login before writting a letter to an asshole" and return if current_user.blank?
    render :text => "params in blank!" and return if params.blank?
    asshole_name = params[:post][:asshole_name]
    content = params[:post][:content]
    
    render :text => "either asshole's name or letter's content is blank!" and return if asshole_name.blank? || content.blank?
    
    data = params[:post]
    data.merge!({
      :user_id => current_user.id,
      :content => content,
      :asshole_name => asshole_name
    })
    
    @post = Post.create(data)
    if @post.save
      flash[:notice] = "Congrats! Your letter to the asshole has been saved!"
      redirect_to user_path(current_user.id)
    else
      respond_to do |format|
        flash[:error] = "Something went wrong while saving your letter"
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit
    @post = Post.find(params[:id])
  end
  
  def update
    render :text => "error: blank params" and return if params[:post].blank?
    @post = Post.find(params[:post][:id])
    if @post.update_attributes params[:post]
      flash[:notice] = "Your changes to the  letter has been saved!"
      redirect_to user_path(current_user.id)
    else
      respond_to do |format|
        flash[:error] = "Something went wrong while saving your letter"
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    render :text => "error: blank id" and return if params[:id].blank?
    @post = Post.find(params[:id])
    if @post.destroy
      flash[:notice] = "Your letter to the asshole has been deleted... why did you do that??"
    else
      flash[:error] = "Something went wrong while saving your letter"
    end
    redirect_to user_path(current_user.id)
  end
  
end