//======== Action Cable Messages =====/

function msg_playerJoined(data){
  var pid = data["params"]["id"];
  var playerObj = {
    email: data["params"]["email"],
    order: data["params"]["order"],
    points: data["params"]["points"],
    played: data["params"]["played"]
  }
  players[pid] = playerObj;
  renderPlayerList();
}

function msg_gameStart(data){
  $("#startingScreen").hide();
  gameState = "playing";
  getWhiteCards();
  getBlackCard();
  cardTzarId = data["params"]["card_tzar"];
}

function msg_cardPlay(data){
  markCardPlayed(data["params"]["fromPlayer"]);

  if(data["params"]["fromPlayer"] != playerId) {
    addFakeWhiteCard(1);
  }

  if(data["callback"]){
    msg_cardTzar(data["callback"]);
  }
  // Check if tzar_choice is in there
}

function msg_cardTzar(data){
  gameState = "picking";
  showPlayedCards(data["params"]["played_cards"]);
  enablePickingButtons();
}

function msg_endRound(data){
  gameState = "scoring";
  markWinningCard(data["params"]["winning_card"]);
  addPoint(data["params"]["winner"]);
  var date = new Date();
  var timestamp = date.getTime();
  setTimeout(function(){
    gameState = "playing";
    clearTable(data["params"]["card_tzar"]);
  }, (data["params"]["clear_table_at"] * 1000) - timestamp);
}

//========= mo shit =========== //

function renderPlayerList(){
  $("#playerList").empty();
  for (id in players){
    $("#playerList").append("<li id='player_"+id+"'>" + players[id]["order"] + " - " + players[id]["email"] + " - " + players[id]["points"] + " - " + players[id]["played"] + "</li>");
  }
}


function getBlackCard(){
  if(gameState == "playing" || gameState == "picking"){
    $.get("/games/" + gameId + "/black_card", function( data ) {
      blackCard = data["card_template"];
      renderBlackCard();
    });
  }
}

function renderBlackCard(){
  $("#black-card").html('\
    <div class="card">\
      <div class="card-body bg-dark">\
        <p class="card-text" id="black-card-text">' + blackCard["text"] + '</p>\
      </div>\
    </div>');
}

function getWhiteCards(callback = ()=>{}){
  if(gameState == "playing" || gameState == "picking"){
    $.get("/games/" + gameId + "/white_cards", function( data ) {
      whiteCards = data;
      renderWhiteCards();
      callback();
    });
  }
}

function renderWhiteCards(){
  var cards = "";
  for(var i=0; i < whiteCards.length; i++){
    cards += '<div class="card" id="card_' + whiteCards[i]["id"] + '">\
      <div class="card-body">\
        <p class="card-text">' + whiteCards[i]["card_template"]["text"] + '</p>\
      </div>\
    </div>'
  }
  $("#white-cards").html(cards);
  evaluateCardTzar();
}

function initCardDropListener(){
  $("#card-drop").droppable({
    drop: function( event, ui ) {
      var cardId = ui.draggable.attr('id').split("_")[1];
      var cardText = ui.draggable.find('.card-text').html();
      $("#card_" + cardId).remove();
      addPlayedCard(cardId, cardText);

      $.get("/games/" + gameId + "/playcard/" + cardId, function( data ) {
        if(!data["success"]){
          console.error(data["error"]);
        }
      });
    }
  });
}

function addPlayedCard(cardId, cardText){
  if(cardId == -1) { return false }
  turnOffDragging();
  $("#card-drop").append('<div class="card" id="card_' + cardId + '">\
    <div class="card-body">\
      <p class="card-text">' + cardText + '</p>\
    </div>\
  </div>');
}

function addFakeWhiteCard(amount){
  for(var i=0; i<amount; i++){
    $("#face-down-whites").append('<div class="card">\
      <div class="card-body">\
        <p class="card-text">Blank</p>\
      </div>\
    </div>');
  }
}

function turnOffDragging(){
  console.log(whiteCards);
  for(var i=0; i < whiteCards.length; i++){
    $("#card_" + whiteCards[i]["id"]).draggable({ revert: "invalid", disabled: true });
  }
}

function turnOnDragging(){
  for(var i=0; i < whiteCards.length; i++){
    $("#card_" + whiteCards[i]["id"]).draggable({ revert: "invalid", disabled: false });
  }
}

function markCardPlayed(playerId){
  players[id].played = true;
  renderPlayerList();
}

function evaluateCardTzar(){
  if(playerId == cardTzarId) {
      // Start button
      if(gameState == "setup"){
        $(".startButton").show();
      }
      else{
        $(".startButton").hide();
      }

      turnOffDragging();
  }
  else {
    turnOnDragging();
  }
}

function showPlayedCards(cards){
  $("#card-drop").hide();
  $("#card-drop").find(".card").remove();
  $("#face-down-whites").empty();
  for(var i=0; i<cards.length; i++) {
    $("#face-down-whites").append('<div class="card" id="card_' + cards[i].id + '">\
      <div class="card-body">\
        <p class="card-text">' + cards[i]["card_template"].text + '</p>\
        <button class="tzar-picker btn btn-primary" onClick="tzarPick(' + cards[i].id + ')" style="display: none">Pick</button>\
      </div>\
    </div>');
  }
}

function enablePickingButtons(){
  if(cardTzarId == playerId && gameState == "picking"){
    $(".tzar-picker").show();
  }
}

function tzarPick(cardId){
  $.get("/games/" + gameId + "/tzarchoice/" + cardId, function( data ) {
  });
}

function markWinningCard(cardId){
  $("#card_" + cardId).css("background-color", "blue");
}

function addPoint(playerId){
  players[playerId]["points"] += 1;
  renderPlayerList();
}

function clearTable(ctId){
  getBlackCard();
  getWhiteCards();
  $("#face-down-whites").empty();
  cardTzarId = ctId;
  renderPlayerList();
}
