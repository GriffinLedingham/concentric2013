// Generated by CoffeeScript 1.6.3
var init;

window.Card = (function() {
  function Card(data) {
    console.log("here");
  }

  return Card;

})();

init = function() {
  var c, guid, s4, socket,
    _this = this;
  c = new Card();
  socket = io.connect('http://localhost:8142');
  socket.on('connect', function() {
    socket.emit('auth', guid());
    return socket.emit('join_room', '1');
  });
  socket.on('message', function(message_data) {});
  s4 = function() {
    return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  };
  return guid = function() {
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
  };
};

$(function() {
  return console.log("jquery");
});
