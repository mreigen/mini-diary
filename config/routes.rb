VideoCloud::Application.routes.draw do
  
  devise_for :users
  
  post "posts/new" => "posts#create"
  match "posts/paginate" => "posts#paginate"
  
  resources :users
  resources :posts
  
  root :to => "posts#new"
end
