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
      @actions
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

      if data.uname is app.username()
        @actions.push
          message: "You played #{data.name}"
      else
        @actions.push
          message: "Your opponent played #{data.name}"

      @cards.push new Card @, data

      $cardvm = $("##{data.id}")
      $cardvm.css "top", (data.y - 210) + 'px'
      $cardvm.css "left", (data.x - 515) + 'px'

    @socket.on "sync_active", (data) =>
      _.each data, (card) =>

        @cards.push new Card @, data

        $cardvm = $("##{card.id}")
        $cardvm.css "top", (card.y - 210) + 'px'
        $cardvm.css "left", (card.x - 515) + 'px'

    @socket.on "SpellCast", (cardId) =>

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
            @actions.push new Action
                message: "#{action.name} is in a better place"
          else
            action.stats.health combat.action.life
            @actions.push new Action
                message: "#{action.name} has taken #{combat.action.damage} damage"

        if target?
          if combat.target.life is 0
            @cards _.without @cards(), target
            @actions.push new Action
                message: "#{target.name} is in a better place"
          else
            target.stats.health combat.target.life
            target.takingDamage null
            target.takingDamage (if combat.target.damage < 0 then "+" + combat.target.damage*-1 else "-" + combat.target.damage)
            @actions.push new Action
                message: "#{target.name} has taken #{combat.target.damage} damage"

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

class Action
  constructor: (data) ->
    currentdate = new Date();
    datetime = currentdate.getDate() + "/" +
      (currentdate.getMonth()+1)  + "/" +
      currentdate.getFullYear() + " @ " +
      currentdate.getHours() + ":" +
      currentdate.getMinutes() + ":" +
      currentdate.getSeconds()

    @time = ko.observable datetime
    @target = ko.observable null


    @message = ko.observable(data.message or "---")

class AppViewModel
  constructor: () ->

    @username = ko.observable null
    @room = ko.observable null

    @player1 = ko.observable false

    @activeTurn = ko.observable false

    @socket = io.connect(window.location.origin)

    @host = window.location.origin

    @actions = ko.observableArray []

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

    @socket.on "FirstPlayer", (name) =>
      console.log name, @username()
      @player1(name is @username())

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

      if selfDiff isnt 0
        if selfDiff > 0
          @actions.push
            message: "You gained #{selfDiff} life"
          @actions.push
            message: "You lost #{selfDiff*-1} life"

      if opponentDiff isnt 0
        if opponentDiff > 0
          @actions.push
            message: "Your opponent gained #{opponentDiff} life"
          @actions.push
            message: "Your opponent lost #{opponentDiff*-1} life"



    @socket.on "StartTurn", (name) =>

      @actions.push
        message: "Starting turn: #{name}"

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
      @actions.push
        message: "You set your username to #{app.username()}"
    true

  join: (player, ev) =>
    if ev.keyCode is 13
      app.restart()
      @socket.emit 'join_room', @room()
      @actions.push
        message: "You joined room #{@room()}"
    true


app = new AppViewModel

$ ->



  ko.applyBindings(app, $("html").get(0))




