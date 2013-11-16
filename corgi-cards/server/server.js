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

var active_cards = [];

var room_players = [];

io.sockets.on('connection', function (socket) {
	console.log('connected');
	socket.room;
	socket.guid;
  socket.uname;
  socket.deck;
  socket.discard;

  socket.hand = [];

	socket.on('auth',function(guid_in,uname){
		socket.guid = guid_in;
    socket.uname = uname;
	});

  socket.on('load_deck',function(deck){
    socket.deck = deck;

    //Randomize deck here

  });

	socket.on('join_room', function(room){
    if(typeof room_players[room] === 'undefined')
    {
      room_players[room] = [];
    }

    room_players[room].push(socket);
		socket.room = room;
		socket.join(room);
		socket.broadcast.emit('message',{guid:socket.guid,data:socket.uname+' joined the room'});

    if(room_players[room].length === 2)
    {
      //start_game(room_players[room][0], room_players[room][1]);
    }
	});

  socket.on('CardMoved',function(data){
    console.log("Card Moved\n", data)
    var x = data.x;
    var y = data.y;
    var id = data.id;

    active_cards[socket.room][data.id].x = x;
    active_cards[socket.room][data.id].y = y;

    //Emitting an object with a card object, an x and a y
    socket.broadcast.emit('CardMoved',active_cards[socket.room][data.id]);
  });

  socket.on('CardPlayed',function(data){
    console.log("Card Played\n", data)
    if(typeof active_cards[socket.room] === 'undefined')
    {
      active_cards[socket.room] = [];
    }

    var id = data.id;
    var x = data.x;
    var y = data.y;

    active_cards[socket.room][data.id] = data;

    io.sockets.in(socket.room).emit('CardPlayed',active_cards[socket.room][data.id]);
  });
});

/*
 * player1: player1's socket object
 * player2: player2's socket object
 */
function start_game(player1, player2)
{
  player1.hand = [];
  player2.hand = [];

  for(var i = 0;i<5;i++)
  {
    player1.hand.push(player1.deck[i]);
    player2.hand.push(player2.deck[i]);
  }
}
