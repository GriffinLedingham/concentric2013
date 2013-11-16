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

    @cards = ko.observableArray []

    @socket.on 'CardMoved', (data) =>

      card = _.find @cards(), (card) =>
        card.id is data.id

      return unless card

      $cardvm = $("##{card.id}")
      $cardvm.css "top", data.y + 'px'
      $cardvm.css "left", data.x + 'px'


    @socket.on 'CardPlayed', (data) =>
      @cards.push new Card @, {id: data.id, name: data.name, uname: data.uname, type: data.type, position: {x: data.x, y: data.y} }

      $cardvm = $("##{data.id}")
      $cardvm.css "top", data.y + 'px'
      $cardvm.css "left", data.x + 'px'

    @socket.on "sync_active", (data) =>
      _.each data, (card) =>

        @cards.push new Card(@, {id: card.id, name: card.name, uname: card.uname, type: card.type, position: {x: card.x, y: card.y} })

        $cardvm = $("##{card.id}")
        $cardvm.css "top", card.y + 'px'
        $cardvm.css "left", card.x + 'px'

  clear: () =>
    @cards.splice(0)

  dropCard: (data, ui) =>

    card = ko.dataFor ui.helper.get(0)

    @socket.emit 'CardPlayed', {id: card.id, name: card.name, uname: card.uname, type: card.type(), x: card.position()[0], y: card.position()[1]}

  dragstop: (ev, ui) =>

    card = ko.dataFor ui.helper.get(0)

    card.position()[0] = ui.position.left
    card.position()[1] = ui.position.top

    @socket.emit 'CardMoved', {id: card.id, name: card.name, x: ui.position.left, y: ui.position.top}


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



