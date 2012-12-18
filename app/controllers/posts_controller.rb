class PostsController < ApplicationController
  
  def new
    # if user was composing a new post before logging in
    # show the post
    unless session[:new_post].blank?
      @status = "Please click Post when you are ready to post the letter"
      @asshole_name = session[:new_post][:asshole_name]
      @content = session[:new_post][:content]
      session[:new_post] = nil
    end
  end
  
  def index
    @page_size = 4
    @posts = Post.last(@page_size).reverse
    respond_to do |format|
      format.html
    end
  end
  
  # 
  def paginate
    by_user_id = params[:user_id]
    page_size = params[:page_size]
    to_page = params[:to_page]
    
    render :text => "missing page_size" and return if page_size.blank?
    render :text => "missing to_page" and return if to_page.blank?
    
    page_size = page_size.to_i
    to_page = to_page.to_i
    
    render :text => "page_size must be greater than 0" and return if page_size <= 0
    render :text => "to_page must be greater than 0" and return if to_page <= 0
    
    to_page -= 1 # starts with 0 index
    
    @posts = Post.by_user_id(by_user_id).order("created_at DESC").offset(page_size * to_page).limit(page_size).all
    
    render :json => [] if @posts.blank?
    
    # reformat posts
    @formatted_posts = []
    max_content_length = 300
    @posts.each do |p|
      post = {
        :asshole_name => p.asshole_name,
        :content => p.content.length > max_content_length ? p.content.truncate(300) : p.content,
        :continue => p.content.length > max_content_length,
        :created_at => p.created_at.strftime("%b %d, %Y"),
        :post_path => post_path(p.id),
        :user_name => User.find(p.user_id).nickname,
        :user_path => user_path(User.find(p.user_id))
      }
      @formatted_posts.push post
    end
    render :json => @formatted_posts unless @formatted_posts.blank?
  end
  
  def show
    @post = Post.find(params[:id])
    @user_owns_page = !current_user.blank? ? @post.user_id == current_user.id : false
    respond_to do |format|
      format.html
      format.json { render :json => @post }
    end
  end
  
  def create
    render :text => "params is blank!" and return if params[:post].blank?
    asshole_name = params[:post][:asshole_name]
    content = params[:post][:content]
    render :text => "either asshole's name or letter's content is blank!" and return if asshole_name.blank? || content.blank?
    
    if current_user.blank? # if not logged in
      session[:new_post] = {
        :asshole_name => params[:post][:asshole_name], 
        :content => params[:post][:content]
      }
      
      redirect_to "/users/sign_in" and return
    end
    render :text => "please login before writting a letter to an asshole" and return if current_user.blank?
    
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