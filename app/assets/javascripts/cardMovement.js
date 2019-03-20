/*
Locality:
  GLOBAL = executed on local client and remote clients
  LOCAL = exceuted only local client
  REMOTE = executed only on remote clients
*/
function moveCard(cardId, dropZoneId, locality = "GLOBAL"){
  // Local movement
  if(locality == "GLOBAL" || locality == "LOCAL"){
    var cleanCard = $("#card_" + cardId).css("left", "0px").css("top", "0px").remove();
    $("#drop_" + dropZoneId).append(cleanCard);
  }

  // Remote movement
  if(locality == "GLOBAL" || locality == "REMOTE"){
    App.game.send({
      type: "CARD_MOVE",
      params: {
        cardId: cardId,
        dropZoneId: dropZoneId
      },
      fromPlayer: 1
    });
  }

  return true
};
