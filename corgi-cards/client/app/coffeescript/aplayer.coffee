class window.Player
  constructor: (@delegate) ->
    {
      @socket
    } = @delegate

    @hand = ko.observableArray []

    @deck = ko.observableArray []

    @discard = ko.observableArray []


  playCard: (card, ui) =>
    @socket.emit 'CardPlayed', {id: guid(), name: "fuck ya", x: Math.random()*900, y: Math.random()*600}