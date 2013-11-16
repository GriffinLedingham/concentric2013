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
      @cards.push new Card(@, {id: data.id, name: data.name, position: {x: data.x, y: data.y} })

      $cardvm = $("##{data.id}")
      $cardvm.css "top", data.y + 'px'
      $cardvm.css "left", data.x + 'px'


class AppViewModel
  constructor: () ->

    @socket = io.connect(window.location.origin)

    @socket.on 'connect', ->
      @socket.

    @host = window.location.origin

    @board = new Board @

    @player = new Player @


app = new AppViewModel

$ ->



  ko.applyBindings(app, $("html").get(0))



