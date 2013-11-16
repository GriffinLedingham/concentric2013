s4 = =>
  return Math.floor((1 + Math.random()) * 0x10000)
             .toString(16)
             .substring(1)

guid = =>
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
           s4() + '-' + s4() + s4() + s4()



window.socket = io.connect(window.location.origin)

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

    @host = window.location.origin

    @cards = ko.observableArray()
    y = 0
    _.each Cards, (card) =>
      @cards.push new CardViewModel @, {card: card, position: {x:0, y: y}}

      socket.emit 'CardPlayed', {x:0, y: y, card: card}

      y += 120


    socket.on 'CardMoved', (data) =>

      card = _.find @cards(), (card) =>
        card.card.id is data.card.id

      return unless card

      $cardvm = $("##{card.card.id}")


      console.log data

      $cardvm.css "top", data.y + 'px'
      $cardvm.css "left", data.x + 'px'


    socket.on 'CardPlayed', (data) =>
      console.log data
      @cards.push new CardViewModel @, {card: data.card, position: {x: data.x, y: data.y} }


app = new AppViewModel

$ ->



  ko.applyBindings(app, $("html").get(0))



