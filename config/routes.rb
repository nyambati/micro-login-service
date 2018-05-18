Rails.application.routes.draw do
  resources :users, except: [:new, :edit] do
    collection do
      post 'login'
      get 'generate_access_token'
    end
  end

  get "auth/:provider/callback", to: 'users#google_login'
  get 'auth/failure', to: redirect('/')

  post 'password/forgot', to: 'passwords#forgot'

  root to: "users#index"

  resources :invites, only: [:index, :create]
  resources :roles, only: [:index, :show, :create, :destroy, :update]
end
