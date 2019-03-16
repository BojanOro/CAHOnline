class ActionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "action"
  end

  def receive(data)
    ActionCable.server.broadcast("action", data)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
