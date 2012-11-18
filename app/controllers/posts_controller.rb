class PostsController < ApplicationController
  def index
    @posts = Post.last(10)
    respond_to do |format|
      format.html
    end
  end
end