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

var rdw = [];
var control = [];

for(var i =0;i<20;i++)
{
  rdw.push({
              name: 'RDW'+i,
              id: guid(),
              type:'monster'
          });
}

for(var i=0;i<20;i++)
{
  control.push({
              name: 'Control'+i,
              id:guid(),
              type:'spell'
          });
}


io.sockets.on('connection', function (socket) {
	console.log('connected');
	socket.room;
  socket.uname;
  socket.deck;
  socket.discard;

  socket.hand = [];

	socket.on('auth',function(uname){
    socket.uname = uname;
	});

	socket.on('join_room', function(room){
    console.log(room);
    if(typeof room_players[room] === 'undefined')
    {
      room_players[room] = [];
    }



    // TODO: If there are already two people in the room, enter spectator mode.

    room_players[room].push(socket);
		socket.room = room;
		socket.join(room);
    if(active_cards[room] !== undefined){
      socket.emit('sync_active',active_cards[room]);
    }
    if(room_players[room].length === 2)
    {
      start_game(room_players[room][0], room_players[room][1]);
    }
	});

  socket.on('CardMoved',function(data){
    //console.log("Card Moved\n", data)

    var card_index;

    for(var i = 0;i< active_cards[socket.room].length; i++)
    {
      if(active_cards[socket.room][i].id === data.id)
      {
        card_index = i;
        break;
      }
    }

    var x = data.x;
    var y = data.y;
    var id = data.id;

    active_cards[socket.room][card_index].x = x;
    active_cards[socket.room][card_index].y = y;

    //Emitting an object with a card object, an x and a y
    socket.broadcast.emit('CardMoved',active_cards[socket.room][card_index]);
  });

  socket.on('CardPlayed',function(data){
    if(typeof socket.room === 'undefined' || typeof socket.uname === 'undefined')
    {
      return;
    }
    console.log("Card Played\n", data)

    if(typeof active_cards[socket.room] === 'undefined')
    {
      active_cards[socket.room] = [];
    }

    active_cards[socket.room].push(data);

    io.sockets.in(socket.room).emit('CardPlayed',data);
  });

  socket.on('CardToHand',function(data){
    console.log("ASDASDASDASDASD");
    socket.hand.push(data);

    socket.emit('CardToHand',data);
  });

  socket.on('HandMoved',function(data){
    var x = data.x;
    var y = data.y;

  });
});

/*
 * player1: player1's socket object
 * player2: player2's socket object
 */
function start_game(player1, player2)
{
  player1.deck = shuffleArray(rdw);
  for(var i =0;i<player1.deck.length;i++)
  {
    player1.deck[i].uname = player1.uname;
  }
  player2.deck = shuffleArray(control);
  for(var i =0;i<player2.deck.length;i++)
  {
    player2.deck[i].uname = player2.uname;
  }

  player1.hand = [];
  player2.hand = [];

  for(var i = 0;i<5;i++)
  {
    draw_card(player1);
    draw_card(player2);
  }
}

function draw_card(player)
{
    var top_deck = player.deck[0];
    player.hand.push(top_deck);
    player.deck.splice(0,1);

    player.emit('CardDraw',top_deck);
}

function shuffleArray(array) {
    for (var i = array.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        var temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    return array;
}

function s4(){
  return Math.floor((1 + Math.random()) * 0x10000)
             .toString(16)
             .substring(1);
}

function guid(){ 
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
           s4() + '-' + s4() + s4() + s4();
}

