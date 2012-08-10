PersonalPuzzle::Application.routes.draw do

  match "log_in"             => "sessions#new",             :as => "log_in"
  delete "log_out"           => "sessions#destroy"

  get "sign_up" => "users#new", :as => "sign_up"

  # root :to => "tasks#index"
  root :to => "sessions#new"

  resources :users
  resources :sessions
  resources :clients
  resources :tasks

end
