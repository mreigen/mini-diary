class PostsController < ApplicationController
  def index
    @posts = Post.by_month(Time.new.month).last(10)
    respond_to do |format|
      format.html
    end
  end
end