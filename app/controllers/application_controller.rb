class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def after_sign_in_path_for(resource)
    unless session[:new_post].blank?
      new_post_path
    end
  end
end
