class PostsController < ApplicationController
  
  def new
    
  end
  
  def index
    @posts = Post.by_month(Time.new.month).last(10)
    respond_to do |format|
      format.html
    end
  end
  
  def new_post
    params.merge!({
      :user_id => current_user.id
    })
    p = Post.create(params)
    p.save
  end
end