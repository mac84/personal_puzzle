PersonalPuzzle::Application.routes.draw do
  get "/log_in" => "sessions#new", :as => "log_in"
  resource :session, :only => %w[create destroy]

  get "sign_up" => "users#new", :as => "sign_up"

  # root :to => "tasks#index"
  root :to => "sessions#new"

  resources :users
  resources :clients
  resources :tasks

end
