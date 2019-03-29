Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'index#index'
  get 'leaderboard', to: 'index#leaderboard'

  resources :games do
    member do
      get 'play', to: 'games#play'
      get 'white_cards', to: 'games#get_white_cards'
      get 'black_card', to: 'games#get_black_card'
      get 'startgame', to: 'games#start_game'
      get 'playcard/:card_id', to: 'games#play_card'
      get 'tzarchoice/:card_id', to: 'games#tzar_choice'
      get 'leave_game', to: 'games#leave_game'
      get 'register', to: 'games#register'
      post 'password_test', to: 'games#password_test'
    end

  end
end
