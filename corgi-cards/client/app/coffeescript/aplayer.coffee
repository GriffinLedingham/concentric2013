class window.Player
  constructor: (@delegate) ->
    {
      @board
      @socket
    } = @delegate

    @life = ko.observable 30
    @diff = ko.observable false

    @hand = ko.observableArray []

    @deck = ko.observableArray []

    @discard = ko.observableArray []

    @opponentHand = ko.observableArray []

    @strength = ko.observable 0
    @strengthLeft = ko.observable 0

    @strengthCount = ko.computed =>
      @strengthLeft() + '/' + @strength()

    @intel = ko.observable 0
    @intelLeft = ko.observable 0

    @intelCount = ko.computed =>
      @intelLeft() + '/' + @intel()

    @haveUsedResource = ko.observable true

    @myTurn = ko.observable false


    @socket.on "CardDraw", (data) =>
      data.x = Math.random()*1300
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


  addStrength: () =>
    @strength @strength()+1
    @strengthLeft @strengthLeft()+1

    @haveUsedResource true

    @socket.emit "AddStrength"

    false

  addIntel: () =>
    @intel @intel()+1
    @intelLeft @intelLeft()+1

    @haveUsedResource true
    @socket.emit "AddIntel"

    false

  dragstop: (card, ui) =>

    card = ko.dataFor ui.helper.get(0)

    return unless card

    card.x ui.position.left
    card.y ui.position.top

    @socket.emit "HandMoved", {id: card.id, x: ui.position.left, y: ui.position.top}


  isMine: () =>

    true

  canPlay: (card) =>
    if card.type() is 'monster' && card.cost() > @strength()
      return false
    else if card.type() is 'spell' && card.cost() > @intil()
      return false

    true

