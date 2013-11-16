// Generated by CoffeeScript 1.6.3
var AppViewModel, Board, app, guid, s4,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  _this = this;

window.Player = (function() {
  function Player(delegate) {
    var _ref,
      _this = this;
    this.delegate = delegate;
    this.isMine = __bind(this.isMine, this);
    this.dragstop = __bind(this.dragstop, this);
    this.playCard = __bind(this.playCard, this);
    _ref = this.delegate, this.board = _ref.board, this.socket = _ref.socket;
    this.hand = ko.observableArray([]);
    this.deck = ko.observableArray([]);
    this.discard = ko.observableArray([]);
    this.opponentHand = ko.observableArray([]);
    this.socket.on("CardDraw", function(data) {
      var $cardvm, card;
      data.position = {
        x: Math.random() * 200 + 900,
        y: Math.random() * 600
      };
      card = new Card(_this, data);
      _this.hand.push(card);
      $cardvm = $("#" + card.id);
      $cardvm.css("top", data.position.y + 'px');
      $cardvm.css("left", data.position.x + 'px');
      return _this.socket.emit("HandMoved", {
        id: card.id,
        x: data.position.x,
        y: data.position.y
      });
    });
    this.socket.on("CardPlayed", function(data) {
      var card;
      if ((card = _.find(_this.hand(), function(card) {
        return card.id === data.id;
      }))) {
        _this.hand(_.without(_this.hand(), card));
      }
      if ((card = _.find(_this.opponentHand(), function(card) {
        return card.id === data.id;
      }))) {
        return _this.opponentHand(_.without(_this.opponentHand(), card));
      }
    });
    this.socket.on("SyncHand", function(data) {
      return _.each(data, function(card) {
        return _this.hand.push(new Card(_this, card));
      });
    });
    this.socket.on("OpponentDraw", function(data) {
      return _this.opponentHand.push({
        id: data,
        position: {
          x: -100,
          y: -100
        }
      });
    });
    this.socket.on("HandMoved", function(data) {
      var $cardvm, card;
      card = _.find(_this.opponentHand(), function(card) {
        return card.id === data.id;
      });
      if (card != null) {
        card.position.x = data.x;
      }
      if (card != null) {
        card.position.y = data.y;
      }
      $cardvm = $("#" + card.id);
      $cardvm.css("top", data.y + 'px');
      return $cardvm.css("left", data.x + 'px');
    });
  }

  Player.prototype.playCard = function(card, ui) {
    return this.socket.emit('CardToHand', {
      id: guid(),
      name: "fuck ya",
      uname: app.username(),
      position: {
        x: Math.random() * 200 + 900,
        y: Math.random() * 600
      }
    });
  };

  Player.prototype.dragstop = function(card, ui) {
    card = ko.dataFor(ui.helper.get(0));
    if (!card) {
      return;
    }
    card.position()[0] = ui.position.left;
    card.position()[1] = ui.position.top;
    return this.socket.emit("HandMoved", {
      id: card.id,
      x: ui.position.left,
      y: ui.position.top
    });
  };

  Player.prototype.isMine = function() {
    return true;
  };

  return Player;

})();

window.Card = (function() {
  function Card(delegate, data) {
    this.delegate = delegate;
    this.isMine = __bind(this.isMine, this);
    this.socket = this.delegate.socket;
    this.id = data.id;
    this.name = data.name;
    this.type = ko.observable(data.type);
    this.uname = data.uname;
    this.img = data.img;
    this.position = ko.observable([data.position.x, data.position.y]);
  }

  Card.prototype.isMine = function(card, ui) {
    return app.username() === this.uname;
  };

  return Card;

})();

ko.bindingHandlers.draggable = {
  init: function(element, valueAccessor) {
    var options;
    options = ko.utils.unwrapObservable(valueAccessor());
    element = $(element);
    if (options.enabled()) {
      $(element).draggable();
      return $(element).on('drag', options.dragstop);
    }
  }
};

ko.bindingHandlers.droppable = {
  init: function(element, valueAccessor) {
    var options;
    options = ko.utils.unwrapObservable(valueAccessor());
    element = $(element);
    return $(element).droppable(options);
  }
};

s4 = function() {
  return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
};

guid = function() {
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
};

Board = (function() {
  function Board(delegate) {
    var _this = this;
    this.delegate = delegate;
    this.dragstop = __bind(this.dragstop, this);
    this.dropCard = __bind(this.dropCard, this);
    this.clear = __bind(this.clear, this);
    this.socket = this.delegate.socket;
    this.cards = ko.observableArray([]);
    this.socket.on('CardMoved', function(data) {
      var $cardvm, card;
      card = _.find(_this.cards(), function(card) {
        return card.id === data.id;
      });
      if (!card) {
        return;
      }
      $cardvm = $("#" + card.id);
      $cardvm.css("top", data.y + 'px');
      return $cardvm.css("left", data.x + 'px');
    });
    this.socket.on('CardPlayed', function(data) {
      var $cardvm;
      _this.cards.push(new Card(_this, {
        id: data.id,
        name: data.name,
        uname: data.uname,
        type: data.type,
        position: {
          x: data.x,
          y: data.y
        }
      }));
      $cardvm = $("#" + data.id);
      $cardvm.css("top", data.y + 'px');
      return $cardvm.css("left", data.x + 'px');
    });
    this.socket.on("sync_active", function(data) {
      return _.each(data, function(card) {
        var $cardvm;
        _this.cards.push(new Card(_this, {
          id: card.id,
          name: card.name,
          uname: card.uname,
          type: card.type,
          position: {
            x: card.x,
            y: card.y
          }
        }));
        $cardvm = $("#" + card.id);
        $cardvm.css("top", card.y + 'px');
        return $cardvm.css("left", card.x + 'px');
      });
    });
  }

  Board.prototype.clear = function() {
    return this.cards.splice(0);
  };

  Board.prototype.dropCard = function(data, ui) {
    var card;
    card = ko.dataFor(ui.helper.get(0));
    return this.socket.emit('CardPlayed', {
      id: card.id,
      name: card.name,
      uname: card.uname,
      type: card.type(),
      x: card.position()[0],
      y: card.position()[1]
    });
  };

  Board.prototype.dragstop = function(ev, ui) {
    var card;
    card = ko.dataFor(ui.helper.get(0));
    card.position()[0] = ui.position.left;
    card.position()[1] = ui.position.top;
    return this.socket.emit('CardMoved', {
      id: card.id,
      name: card.name,
      x: ui.position.left,
      y: ui.position.top
    });
  };

  return Board;

})();

AppViewModel = (function() {
  function AppViewModel() {
    this.join = __bind(this.join, this);
    this.login = __bind(this.login, this);
    this.restart = __bind(this.restart, this);
    this.username = ko.observable(null);
    this.room = ko.observable(null);
    this.socket = io.connect(window.location.origin);
    this.host = window.location.origin;
    this.board = new Board(this);
    this.player = new Player(this);
  }

  AppViewModel.prototype.restart = function() {
    this.board.clear();
    this.player.hand.splice(0);
    this.player.deck.splice(0);
    return this.player.discard.splice(0);
  };

  AppViewModel.prototype.login = function(player, ev) {
    if (ev.keyCode === 13) {
      this.socket.emit('auth', app.username());
    }
    return true;
  };

  AppViewModel.prototype.join = function(player, ev) {
    if (ev.keyCode === 13) {
      app.restart();
      this.socket.emit('join_room', this.room());
    }
    return true;
  };

  return AppViewModel;

})();

app = new AppViewModel;

$(function() {
  return ko.applyBindings(app, $("html").get(0));
});
