s4 = =>
  return Math.floor((1 + Math.random()) * 0x10000)
             .toString(16)
             .substring(1)

guid = =>
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
           s4() + '-' + s4() + s4() + s4()


c1 = new Card

init = ->
  c = new Card()

  canvas = document.getElementById('canvas')
  stage = new createjs.Stage(canvas)
  shape = new createjs.Shape()
  shape.graphics.beginFill('rgba(255,0,0,1)').drawRoundRect(0, 0, 120, 120, 0)
  stage.addChild(shape)
  stage.update()


  socket = io.connect('http://localhost:8142')

  socket.on 'connect', ->
    socket.emit 'auth', guid()
    socket.emit 'join_room','1'

  socket.on 'message', (message_data) ->


$ ->



