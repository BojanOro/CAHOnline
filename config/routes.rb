Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'index#index'
  post 'message', to: 'index#incoming_message'

  resources :games do
    member do
      get 'join', to: 'games#join'
    end
  end
end
