Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'index#index'
  post 'message', to: 'index#incoming_message'

  resources :games do
    member do
      get 'play', to: 'games#play'
      get 'white_cards', to: 'games#get_white_cards'
      get 'startgame', to: 'games#start_game'
      get 'playcard/:card_id', to: 'games#play_card'
      get 'tzarchoice/:card_id', to: 'games#tzar_choice'
    end

  end
end
