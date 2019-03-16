class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params['game_id']}"
  end

  def receive(data)
    ActionCable.server.broadcast("game_#{params['game_id']}", data)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
