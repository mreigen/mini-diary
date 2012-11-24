VideoCloud::Application.routes.draw do
  
  devise_for :users
  
  resources :users
  resources :posts
  
  match "posts/new" => "posts#create"
  root :to => "posts#new"
end
