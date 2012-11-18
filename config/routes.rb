VideoCloud::Application.routes.draw do
  
  devise_for :users
  
  resources :users
  
  root :to => "posts#index"
end
