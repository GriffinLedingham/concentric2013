class window.Player
  constructor: (@delegate) ->
    {
      @board
      @socket
    } = @delegate



    @hand = ko.observableArray []

    @deck = ko.observableArray []

    @discard = ko.observableArray []

    @opponentHand = ko.observableArray []

    @socket.on "CardDraw", (data) =>
      data.position = {x: Math.random()*200 + 900, y: Math.random()*600}
      card = new Card @, data
      @hand.push card

      $cardvm = $("##{card.id}")
      $cardvm.css "top", data.position.y + 'px'
      $cardvm.css "left", data.position.x + 'px'

      @socket.emit "HandMoved", {id: card.id, x: data.position.x, y: data.position.y}

    @socket.on "CardPlayed", (data) =>
      if (card = (_.find @hand(), (card) => card.id is data.id))
        @hand _.without @hand(), card

      if (card = (_.find @opponentHand(), (card) => card.id is data.id))
        @opponentHand _.without @opponentHand(), card      

    @socket.on "SyncHand", (data) =>
      _.each data, (card) =>
        @hand.push new Card(@, card)

    @socket.on "OpponentDraw", (data) =>
      @opponentHand.push {id: data, position: {x: -100, y: -100}}

    @socket.on "HandMoved", (data) =>
      card = _.find @opponentHand(), (card) =>
        card.id is data.id

      card?.position.x = data.x
      card?.position.y = data.y

      $cardvm = $("##{card.id}")

      $cardvm.css "top", data.y + 'px'
      $cardvm.css "left", data.x + 'px'


  playCard: (card, ui) =>
    @socket.emit 'CardToHand', {id: guid(), name: "fuck ya", uname: app.username(), position: {x: Math.random()*200 + 900, y: Math.random()*600} }

  dragstop: (card, ui) =>

    card = ko.dataFor ui.helper.get(0)

    return unless card

    card.position()[0] = ui.position.left
    card.position()[1] = ui.position.top

    @socket.emit "HandMoved", {id: card.id, x: ui.position.left, y: ui.position.top}


  isMine: () =>
    true