// Generated by CoffeeScript 1.6.2
var AppViewModel, Cards, app, c1, c2, guid, s4,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  _this = this;

window.Card = (function() {
  function Card(data) {
    this.id = data.id;
    this.name = data.name;
    this.img = data.img;
  }

  return Card;

})();

window.monsters = (function() {
  function monsters(data) {}

  return monsters;

})();

window.spell = (function() {
  function spell(data) {}

  return spell;

})();

window.CardViewModel = (function() {
  function CardViewModel(delegate, data) {
    this.delegate = delegate;
    this.dragstop = __bind(this.dragstop, this);
    this.delegate;
    this.card = data.card;
    this.position = ko.observable([data.position.x, data.position.y]);
  }

  CardViewModel.prototype.dragstop = function(ev, ui) {
    this.position()[0] = $(ui.target).css("top");
    this.position()[1] = $(ui.target).css("left");
    return socket.emit('CardMoved', {
      x: ui.position.left,
      y: ui.position.top,
      card: this.card
    });
  };

  return CardViewModel;

})();

ko.bindingHandlers.draggable = {
  init: function(element, valueAccessor) {
    var options;

    options = ko.utils.unwrapObservable(valueAccessor());
    element = $(element);
    $(element).draggable();
    return $(element).on('dragstop', options.dragstop);
  }
};

s4 = function() {
  return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
};

guid = function() {
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
};

window.socket = io.connect(window.location.origin);

socket.on('connect', function() {
  socket.emit('auth', guid());
  return socket.emit('join_room', '1');
});

c1 = new Card({
  id: guid(),
  name: "poop"
});

c2 = new Card({
  id: guid(),
  name: "thing2"
});

Cards = [c1, c2];

AppViewModel = (function() {
  function AppViewModel() {
    var y,
      _this = this;

    this.host = window.location.origin;
    this.cards = ko.observableArray();
    y = 0;
    _.each(Cards, function(card) {
      _this.cards.push(new CardViewModel(_this, {
        card: card,
        position: {
          x: 0,
          y: y
        }
      }));
      socket.emit('CardPlayed', {
        x: 0,
        y: y,
        card: card
      });
      return y += 120;
    });
    socket.on('CardMoved', function(data) {
      var $cardvm, card;

      card = _.find(_this.cards(), function(card) {
        return card.card.id === data.card.id;
      });
      if (!card) {
        return;
      }
      $cardvm = $("#" + card.card.id);
      console.log(data);
      $cardvm.css("top", data.y + 'px');
      return $cardvm.css("left", data.x + 'px');
    });
    socket.on('CardPlayed', function(data) {
      console.log(data);
      return _this.cards.push(new CardViewModel(_this, {
        card: data.card,
        position: {
          x: data.x,
          y: data.y
        }
      }));
    });
  }

  return AppViewModel;

})();

app = new AppViewModel;

$(function() {
  return ko.applyBindings(app, $("html").get(0));
});
