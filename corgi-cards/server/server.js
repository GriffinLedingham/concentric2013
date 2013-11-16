var fs = require('fs')
var http = require('http');
var express = require('express');

var app = express()

app.use(express.static("client/public"));

var server = http.createServer(app);

//app.listen(8142);

var io = require('socket.io').listen(server);	

server.listen(8142);

io.set('log level', 0);

io.sockets.on('connection', function (socket) {
	console.log('connected');
	socket.room;
	socket.guid;
  socket.uname;

	socket.on('auth',function(guid_in,uname){
		socket.guid = guid_in;
    socket.uname = uname;
	});

	socket.on('join_room', function(room){
		socket.room = room;
		socket.join(room);
		socket.broadcast.emit('message',{guid:socket.guid,data:socket.uname+' joined the room'});
	});

  socket.on('message',function(data){

  });
});
