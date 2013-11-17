class window.Card
  constructor: (@delegate, data) ->
    {
      @socket
    } = @delegate

    @id = data.id
    @name = data.name

    @type = ko.observable data.type

    @uname = data.uname

    @img = data.img

    @x = ko.observable data.x
    @y = ko.observable data.y

    @stats = new Stats data.stats

    @takingDamage = ko.observable false

    @tapped = ko.observable false

    @cost = ko.observable -1

  isMine: (card, ui) =>
    app.username() is @uname


class window.Stats
  constructor: (stats) ->

    @attack = ko.observable(if stats.attack? then stats.attack else -1)
    @health = ko.observable(if stats.health? then stats.health else -1)
    @baseHealth = ko.observable(if stats.health? then stats.health else -1)
    @cost = ko.observable(if stats.cost? then stats.cost else -1)

class window.Ability
  constructor: (@type, @value) ->
