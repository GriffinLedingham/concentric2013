s4 = =>
  return Math.floor((1 + Math.random()) * 0x10000)
             .toString(16)
             .substring(1)

guid = =>
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
           s4() + '-' + s4() + s4() + s4()


class Board
  constructor: (@delegate) ->
    {
      @socket
    } = @delegate

    @action = ko.observable null
    @target = ko.observable null

    @cards = ko.observableArray []

    @socket.on 'CardMoved', (data) =>

      card = _.find @cards(), (card) =>
        card.id is data.id

      return unless card

      $cardvm = $("##{card.id}")
      $cardvm.css "top", data.y + 'px'
      $cardvm.css "left", data.x + 'px'


    @socket.on 'CardPlayed', (data) =>

      @cards.push new Card @, data

      $cardvm = $("##{data.id}")
      $cardvm.css "top", (data.y) + 'px'
      $cardvm.css "left", (data.x - 200) + 'px'

    @socket.on "sync_active", (data) =>
      _.each data, (card) =>

        @cards.push new Card @, data

        $cardvm = $("##{card.id}")
        $cardvm.css "top", (card.y) + 'px'
        $cardvm.css "left", (card.x - 200) + 'px'

    @socket.on "CardInteraction", (data) =>

      if data.type is 'attack'

        combat = data.result

        action = _.find @cards(), (card) =>
          card.id is combat.action.id

        target = _.find @cards(), (card) =>
            card.id is combat.target.id

        if combat.action.life is 0
          @cards _.without @cards(), action
        else
          action.stats.health combat.action.life

        if combat.target.life is 0
          @cards _.without @cards(), target
        else
          target.stats.health combat.target.life

      else if data.type is 'spell'
        console.log "spell was cast on yo MUTHAFUCKIN FACE"

      @action null
      @target null

  clear: () =>
    @cards.splice(0)

  dropCard: (data, ui) =>

    card = ko.dataFor ui.helper.get(0)

    @socket.emit 'CardPlayed', card.id

  dragstop: (ev, ui) =>

    card = ko.dataFor ui.helper.get(0)

    card.x ui.position.left
    card.y ui.position.top

    @socket.emit 'CardMoved', {id: card.id, name: card.name, x: ui.position.left, y: ui.position.top}

  handleCardClick: (card, ui) =>

    if card.isMine(card)
      if @action() is card
        @action null
      else @action card

    else
      if @target() is card
        @target null
      else @target card

    if @action() and @target()
      @socket.emit "CardInteraction", @action().id, @target().id

    false

  handleBoardClick: (board, ui) =>
    console.log "here"
    @action null
    @target null

  handleSelfClick: =>
    @target "self"

  handleOpponentClick: =>
    @target "opponent"

class AppViewModel
  constructor: () ->

    @username = ko.observable null
    @room = ko.observable null

    @socket = io.connect(window.location.origin)

    @host = window.location.origin

    @board = new Board @

    @player = new Player @

  restart: () =>
    @board.clear()
    @player.hand.splice 0
    @player.deck.splice 0
    @player.opponentHand.splice 0
    @player.discard.splice 0

  login: (player, ev) =>
    if ev.keyCode is 13
      @socket.emit 'auth', app.username()

    true

  join: (player, ev) =>
    if ev.keyCode is 13
      app.restart()
      @socket.emit 'join_room', @room()

    true


app = new AppViewModel

$ ->



  ko.applyBindings(app, $("html").get(0))



