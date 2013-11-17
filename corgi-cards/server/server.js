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
  var name = 'RDW'+1;
  var stats_obj = getStats(name);
  rdw.push({
              name: name,
              id: guid(),
              type:'monster',
              stats:stats_obj
          });
}

for(var i=0;i<20;i++)
{
  var name = 'Control'+1;
  var stats_obj = getStats(name);
  control.push({
              name: name,
              id:guid(),
              type:'spell',
              stats:stats_obj
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
    console.log("Player joined room: ", room);
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
      if(room_players[room] !== 'undefined')
      {
        if(room_players[room][0] !== 'undefined')
        {
          if(room_players[room][0].uname === socket.uname)
          {
            console.log(room_players[room][0].hand, "@@@");
            socket.emit('SyncHand',room_players[room][0].hand);
            var opponent_hand = [];
            for(var i = 0;i< room_players[room][1].hand.length;i++)
            {
              opponent_hand.push({id:room_players[room][1].hand[i].id,x:room_players[room][1].hand[i].x,y:room_players[room][1].hand[i].y});
            }

            socket.emit('SyncOpponentHand', opponent_hand);
          }
        }

        if(room_players[room][1] !== 'undefined')
        {
          if(room_players[room][1].uname === socket.uname)
          {
            socket.emit('SyncHand',room_players[room][1].hand);
            var opponent_hand = [];
            for(var i = 0;i< room_players[room][0].hand.length;i++)
            {
              opponent_hand.push({id:room_players[room][0].hand[i].id,x:room_players[room][0].hand[i].x,y:room_players[room][0].hand[i].y});
            }

            socket.emit('SyncOpponentHand', opponent_hand);
          }
        }
      }

    }
    if(room_players[room].length === 2)
    {
      start_game(room_players[room][0], room_players[room][1]);
      active_cards[room] = [];
    }
  });

  socket.on('CardMoved',function(data){
    console.log("Card Moved\n", data)

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

  socket.on('HandMoved',function(data){
    console.log("Hand Moved\n", data)

    for(var i = 0;i<socket.hand.length;i++)
    {
      if(socket.hand[i].id === data.id)
      {
        socket.hand[i].x = data.x;
        socket.hand[i].y = data.y;
        break;
      }
    }

    socket.broadcast.emit('HandMoved',{x:data.x,y:data.y,id:data.id});
  });

  socket.on('CardPlayed',function(data){
    if(typeof socket.room === 'undefined' || typeof socket.uname === 'undefined')
    {
      return;
    }

    var card;
    for(var i = 0;i<socket.hand;i++)
    {
      if(socket.hand[i].id === data)
      {
        card = socket.hand[i];
        break;
      }
    }
    if(typeof card === 'undefined')
    {
      return;
    }

    console.log("Card Played\n", card)

    if(typeof active_cards[socket.room] === 'undefined')
    {
      active_cards[socket.room] = [];
    }



    active_cards[socket.room].push(card);
    for(var i = 0; i < socket.hand.length; i++) {
      if(socket.hand[i].id === card.id){
        socket.hand.splice(i, 1)
        break;
      }
    }

    io.sockets.in(socket.room).emit('CardPlayed',card);

  });

  socket.on('CardToHand',function(data){
    socket.hand.push(data);

    socket.emit('CardToHand',data);
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

    player.broadcast.emit('OpponentDraw',top_deck.id);
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

function getStats(name)
{
  //{attack:,health:,special:}

  //Switch statement
  switch(name)
  {
    case 'RDW1':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW2':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW3':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW4':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW5':
      return {attack:1,health:2,special:null};
      break;
    case 'RDW6':
      return {attack:1,health:2,special:null};
      break;
    case 'RDW7':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW8':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW9':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW10':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW11':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW12':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW13':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW14':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW15':
      return {attack:1,health:2,special:null};
      break;
    case 'RDW16':
      return {attack:1,health:2,special:null};
      break;
    case 'RDW17':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW18':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW19':
      return {attack:1,health:1,special:null};
      break;
    case 'RDW20':
      return {attack:1,health:1,special:null};
      break; 
    case 'Control1':
      return {attack:1,health:1,special:null};
      break;
    case 'Control2':
      return {attack:1,health:1,special:null};
      break;
    case 'Control3':
      return {attack:1,health:1,special:null};
      break;
    case 'Control4':
      return {attack:1,health:1,special:null};
      break;
    case 'Control5':
      return {attack:1,health:2,special:null};
      break;
    case 'Control6':
      return {attack:1,health:2,special:null};
      break;
    case 'Control7':
      return {attack:1,health:1,special:null};
      break;
    case 'Control8':
      return {attack:1,health:1,special:null};
      break;
    case 'Control9':
      return {attack:1,health:1,special:null};
      break;
    case 'Control10':
      return {attack:1,health:1,special:null};
      break;
    case 'Control11':
      return {attack:1,health:1,special:null};
      break;
    case 'Control12':
      return {attack:1,health:1,special:null};
      break;
    case 'Control13':
      return {attack:1,health:1,special:null};
      break;
    case 'Control14':
      return {attack:1,health:1,special:null};
      break;
    case 'Control15':
      return {attack:1,health:2,special:null};
      break;
    case 'Control16':
      return {attack:1,health:2,special:null};
      break;
    case 'Control17':
      return {attack:1,health:1,special:null};
      break;
    case 'Control18':
      return {attack:1,health:1,special:null};
      break;
    case 'Control19':
      return {attack:1,health:1,special:null};
      break;
    case 'Control20':
      return {attack:1,health:1,special:null};
      break;
  }
}

