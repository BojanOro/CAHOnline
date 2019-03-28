class GamesController < ApplicationController
    def create
      game = Game.create(name: params['game']['name'], password: params['game']['password'], state: "setup" )
      game.add_user(current_user)
      game.next_card_tzar
      redirect_to play_game_path(game)
      #TODO: set max points parameter in creation
    end

    def play
      # Assign the user to the game
      game = Game.find(params['id'])
      game.add_user(current_user)
      ActionCable.server.broadcast("game_#{game.id}", {
        type: "PLAYER_JOINED",
        params: {
          email: current_user.email,
          points: current_user.game_points,
          id: current_user.id,
          order: current_user.join_order,
          played: current_user.played_card?
        }
      })

      @players = game.users
      @cardTzar = game.card_tzar&.id || -1
      @game = game
      #@played_cards = User.get_played_card

      render "playtwo"
    end

    #after card tzar presses start
    def start_game
      game = Game.find(params['id'])
      game.setup
      game.deal_cards
      black_card = game.draw_black_card
      game.update_attributes(state: "playing")
      ActionCable.server.broadcast("game_#{game.id}", {
        type: "GAME_START",
        params: {
          card_tzar: game.card_tzar.id
        }
      })
      render json: {success: true}
    end

    def get_white_cards
      render json: current_user.cards
    end

    def get_black_card
      game = Game.find(params['id'])
      render json: game.active_black_card
    end

    def play_card
      game = Game.find(params['id'])
      card = Card.find(params['card_id'])

      if card.user != current_user
        render json: {success: false, error: "You do not own this card"}
        return false
      end

      status = game.add_active_card(card)
      if not status
        render json: {success: false, error: "You have already played a card"}
        return false
      end

      message = {
        type: "CARD_PLAY",
        params: {
          fromPlayer: current_user.id
        }
      }

      if game.all_played?
        game.flip_played_cards
        game.update_attributes(state: "picking")
        message["callback"] = {
          type: "TZAR_CHOICE",
          params: {
            card_tzar: game.card_tzar.id,
            played_cards: game.white_played
          }
        }
      end
      render json: {success: true}

      ActionCable.server.broadcast("game_#{game.id}", message)
    end

    def tzar_choice
      game = Game.find(params['id'])
      card = Card.find(params['card_id'])

      game.winning_card(card)
      game.clear_played_cards
      game.refill_hands
      black_card = game.draw_black_card
      card_tzar = game.next_card_tzar

      ActionCable.server.broadcast("game_#{game.id}", {
        type: "END_ROUND",
        params: {
          winner: card.user.id,
          winning_card: card.id,
          black_card: black_card,
          card_tzar: card_tzar.id,
          clear_table_at: Time.now.to_i + 15
        }
      })
    end

    #TODO: exit function in front
    def user_exit
      game = Game.find(params['id'])
      if current_user == game.card_tzar
        game.next_card_tzar
      end
      game.remove_user(current_user)
    end
end
