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

    @socket.on "CardToHand", (data) =>
      @hand.push new Card @, data

    @socket.on "CardPlayed", (data) =>
      if (card = (_.find @hand(), (card) => card.id is data.id))
        @hand _.without @hand(), card


  playCard: (card, ui) =>
    @socket.emit 'CardToHand', {id: guid(), name: "fuck ya", position: {x: Math.random()*200 + 900, y: Math.random()*600} }

  login: (player, ev) =>
    if ev.keyCode is 13
      @socket.emit 'auth', @username()

    true

  join: (player, ev) =>
    if ev.keyCode is 13
      app.restart()
      @socket.emit 'join_room', @room()

    true

  dragstop: (card, ui) =>

    card = ko.dataFor ui.helper.get(0)

    return unless card

    card.position()[0] = ui.position.left
    card.position()[1] = ui.position.top

