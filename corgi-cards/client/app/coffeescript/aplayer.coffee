class window.Player
  constructor: (@delegate) ->
    {
      @board
      @socket
    } = @delegate



    @hand = ko.observableArray []

    @deck = ko.observableArray []

    @discard = ko.observableArray []

    @socket.on "CardDraw", (data) =>
      data.position = {x: Math.random()*200 + 900, y: Math.random()*600}
      card = new Card @, data
      @hand.push card

    @socket.on "CardPlayed", (data) =>
      if (card = (_.find @hand(), (card) => card.id is data.id))
        @hand _.without @hand(), card


  playCard: (card, ui) =>
    @socket.emit 'CardToHand', {id: guid(), name: "fuck ya", uname: app.username(), position: {x: Math.random()*200 + 900, y: Math.random()*600} }

  dragstop: (card, ui) =>

    card = ko.dataFor ui.helper.get(0)

    return unless card

    card.position()[0] = ui.position.left
    card.position()[1] = ui.position.top


  isMine: () =>
    true