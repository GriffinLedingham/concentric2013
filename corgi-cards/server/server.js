var fs = require('fs')
var app = require('http').createServer(handler);
app.listen(8142);

var io = require('socket.io').listen(app);		  
io.set('log level', 0);

io.sockets.on('connection', function (socket) {
	console.log('connected');
	socket.room;
	socket.guid;

	socket.on('auth',function(guid_in){
		socket.guid = guid_in;
	});

	socket.on('join_room', function(room){
		socket.room = room;
		socket.join(room);
		socket.broadcast.emit('message',{guid:socket.guid,data:socket.guid+' joined the room'});
	});
});

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }
 
    res.writeHead(200);
    res.end(data);
  });
}
