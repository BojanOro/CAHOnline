class GamesController < ApplicationController
    def play
        # Assign the user to the game
        current_user.update(game: Game.find(params['id']))
    end
end
