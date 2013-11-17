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
      @activeTurn
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

    @socket.on "SpellCast", (cardId) =>
      console.log cardId
      if (card = (_.find @cards(), (card) => card.id is cardId))
        @cards _.without @cards(), card

      @target null
      @action null

    @socket.on "CardInteraction", (data) =>

      if data.type is 'attack'

        combat = data.result

        action = _.find @cards(), (card) =>
          card.id is combat.action?.id

        target = _.find @cards(), (card) =>
            card.id is combat.target.id

        if action?
          if combat.action.life is 0
            @cards _.without @cards(), action
          else
            action.stats.health combat.action.life

        if combat.target.life is 0
          @cards _.without @cards(), target
        else
          target.stats.health combat.target.life
          target.takingDamage null
          target.takingDamage (if combat.target.damage < 0 then "+" + combat.target.damage*-1 else "-" + combat.target.damage)

      else if data.type is 'spell'
        console.log "spell was cast on yo MUTHAFUCKIN FACE"

      @action null
      @target null

  clear: () =>
    @cards.splice(0)

  dropCard: (data, ui) =>
    return unless @activeTurn()
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

      action = if _.isString(@action()) then @action() else @action().id
      target = if _.isString(@target()) then @target() else @target().id

      @socket.emit "CardInteraction", action, target

    false

  handleBoardClick: (board, ui) =>
    console.log "here"
    @action null
    @target null

  handleSelfClick: =>
    if @target() isnt "self"
      @target "self"
    else @target null

    if @action() and @target()

      action = if _.isString(@action()) then @action() else @action().id
      target = if _.isString(@target()) then @target() else @target().id

      @socket.emit "CardInteraction", action, target

  handleOpponentClick: =>
    if @target() isnt "opponent"
      @target "opponent"
    else @target null

    if @action() and @target()

      action = if _.isString(@action()) then @action() else @action().id
      target = if _.isString(@target()) then @target() else @target().id

      @socket.emit "CardInteraction", action, target

class AppViewModel
  constructor: () ->

    @username = ko.observable null
    @room = ko.observable null

    @activeTurn = ko.observable false


    @socket = io.connect(window.location.origin)

    @host = window.location.origin

    @board = new Board @

    @activeTurn.subscribe (val) =>
      if val
        _.each @board.cards(), (card) =>
          if card.uname is @username()
            $("##{card.id}").draggable("enable");
      else
        _.each @board.cards(), (card) =>
          if card.uname is @username()
            $("##{card.id}").draggable("option", "disabled", true)

    @self = new Player @, "self"
    @opponent = new Player @, "opponent"

    @socket.on "PlayerLife", (data) =>
      selfLife = data.self
      opponentLife = data.opponent

      selfDiff = selfLife - @self.life()
      opponentDiff = opponentLife - @opponent.life()

      @self.diff null
      @opponent.diff null

      @self.diff selfDiff
      @opponent.diff opponentDiff

      @self.life selfLife
      @opponent.life opponentLife

    @socket.on "StartTurn", (name) =>
      console.log 'starting ' + name
      if name isnt @username() then @activeTurn false
      else @activeTurn true

      if @activeTurn()

        @self.haveUsedResource false
        @self.strengthLeft @self.strength()
        @self.intelLeft @self.intel()




    @socket.on "AddStrength", (data) =>

      me = data.uname is @username()

      if me
        @self.strengthLeft data.value
        @self.strength data.cumulative

      else
        @opponent.strengthLeft data.value
        @opponent.strength data.cumulative

    @socket.on "AddIntel", (data) =>

      me = data.uname is @username()

      if me
        @self.intelLeft data.value
        @self.intel data.cumulative

      else
        @opponent.intelLeft data.value
        @opponent.intel data.cumulative


  endTurn: () =>
    @socket.emit "EndTurn"

  restart: () =>
    @board.clear()
    @self.hand.splice 0
    @self.deck.splice 0
    @self.opponentHand.splice 0
    @self.discard.splice 0

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




