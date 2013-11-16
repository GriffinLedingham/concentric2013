class window.Player
  constructor: (@delegate) ->
    {
      @board
      @socket
    } = @delegate

    @username = ko.observable null
    @room = ko.observable null

    @hand = ko.observableArray []

    @deck = ko.observableArray []

    @discard = ko.observableArray []


  playCard: (card, ui) =>
    @socket.emit 'CardPlayed', {id: guid(), name: "fuck ya", x: Math.random()*900, y: Math.random()*600}

  login: (player, ev) =>
    if ev.keyCode is 13
      @socket.emit 'auth', @username()

    true

  join: (player, ev) =>
    if ev.keyCode is 13
      @board.clear()
      @socket.emit 'join_room', @room()

    true

  woo: () =>
    console.log "ashir"