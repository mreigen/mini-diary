VideoCloud::Application.routes.draw do
  
  devise_for :users
  
  resources :users
  resources :posts
  
  root :to => "posts#index"
end
