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
      data.x = Math.random()*500
      data.y = 700
      card = new Card @, data
      @hand.push card

      $cardvm = $("##{card.id}")
      $cardvm.css "top", data.y + 'px'
      $cardvm.css "left", data.x + 'px'

      @socket.emit "HandMoved", {id: card.id, x: data.x, y: data.y}

    @socket.on "CardPlayed", (data) =>
      if (card = (_.find @hand(), (card) => card.id is data.id))
        @hand _.without @hand(), card

      if (card = (_.find @opponentHand(), (card) => card.id is data.id))
        @opponentHand _.without @opponentHand(), card

    @socket.on "SyncHand", (data) =>
      console.log data
      _.each data, (card) =>
        @hand.push new Card(@, card)

        $cardvm = $("##{card.id}")

        $cardvm.css "top", card.y + 'px'
        $cardvm.css "left", card.x + 'px'


    @socket.on "OpponentDraw", (data) =>
      @opponentHand.push {id: data, x: -100, y: -100}

    @socket.on "HandMoved", (data) =>
      card = _.find @opponentHand(), (card) =>
        card.id is data.id

      card?.x = data.x
      card?.y = data.y
      $cardvm = $("##{data.id}")

      $cardvm.css "top", data.y + 'px'
      $cardvm.css "left", data.x + 'px'

    @socket.on "SyncOpponentHand", (data) =>
      _.each data, (card) =>
        @opponentHand.push card

        $cardvm = $("##{card.id}")

        $cardvm.css "top", card.y + 'px'
        $cardvm.css "left", card.x + 'px'

    @socket.on "PlayerLifeChange", (data) =>


  dragstop: (card, ui) =>

    card = ko.dataFor ui.helper.get(0)

    return unless card

    card.x ui.position.left
    card.y ui.position.top

    @socket.emit "HandMoved", {id: card.id, x: ui.position.left, y: ui.position.top}


  isMine: () =>
    true


