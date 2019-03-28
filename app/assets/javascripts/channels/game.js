$( document ).ready(function() {
  App.game = App.cable.subscriptions.create(
    {
      channel: 'GameChannel',
      game_id: document.getElementById('game_id').innerHTML
    }, {
    connected: function() {
      // Called when the subscription is ready for use on the server
      console.log("Connected");
    },

    disconnected: function() {
      // Called when the subscription has been terminated by the server
    },

    received: function(data) {
      // Called when there's incoming data on the websocket for this channel
      console.log("Recieved");
      console.log(data);

      switch(data["type"]){
        case "PLAYER_JOINED":
          msg_playerJoined(data);
          break;

        case "GAME_START":
          msg_gameStart(data);
          break;

        case "CARD_PLAY":
          msg_cardPlay(data);
          break;

        case "END_ROUND":
          msg_endRound(data);
          break;
      }
    }
  });
});
