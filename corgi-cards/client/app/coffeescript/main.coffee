s4 = =>
  return Math.floor((1 + Math.random()) * 0x10000)
             .toString(16)
             .substring(1)

guid = =>
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
           s4() + '-' + s4() + s4() + s4()



window.socket = io.connect('http://localhost:8142')

socket.on 'connect', ->
  socket.emit 'auth', guid()
  socket.emit 'join_room','1'

c1 = new Card
  id: guid()
  name: "poop"

c2 = new Card
  id: guid()
  name: "thing2"


Cards = [c1, c2]

class AppViewModel
  constructor: () ->

    @cards = ko.observableArray()
    y = 0
    _.each Cards, (card) =>
      @cards.push new CardViewModel @, {card: card, position: {x:0, y: y}}

      socket.emit 'CardPlayed', =>
        {x: position[0], y: position[1], card: @card.card}

      y += 120


    socket.on 'CardMoved', (data) =>
      card = _.find @cards(), (card) =>
        card.id is data.card.id

      return unless card

      $cardvm = $("#{card.id}")
      $cardvm.css "top", data.y
      $cardvm.css "left", data.x


    socket.on 'CardPlayed', (data) =>
      data.card

      @cards.push new CardViewModel @, {card: card, x: data.x, y: data.y}

      return unless card

      $cardvm = $("#{card.id}")
      $cardvm.css "top", data.y
      $cardvm.css "left", data.x


app = new AppViewModel

$ ->



  ko.applyBindings(app, $("html").get(0))



