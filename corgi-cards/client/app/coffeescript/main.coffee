
init = ->
  c = new Card()

  socket = io.connect('http://localhost:8142')

  socket.on 'connect', ->
  	socket.emit 'auth', guid() 	
  	socket.emit 'join_room','1' 		  			  			  						  	
  
  socket.on 'message', (message_data) ->
  
  s4 = => 
    return Math.floor((1 + Math.random()) * 0x10000)
               .toString(16)
               .substring(1)
  
  guid = =>
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
           s4() + '-' + s4() + s4() + s4()
  
$ ->
  console.log "jquery"