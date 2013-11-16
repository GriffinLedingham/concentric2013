var fs = require('fs')
var app = require('http').createServer(handler);
app.listen(8080);

var io = require('socket.io').listen(app);		  
io.set('log level', 0);

io.sockets.on('connection', function (socket) {
	socket.on('',function(){

	});
});
