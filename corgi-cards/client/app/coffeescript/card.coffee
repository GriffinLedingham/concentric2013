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


  isMine: (card, ui) =>
    app.username() is @uname


class window.Stats
  constructor: (stats) ->

    @attack = ko.observable(if stats.attack? then stats.attack else "")
    @health = ko.observable(if stats.health? then stats.health else "")
    @baseHealth = ko.observable(if stats.health? then stats.health else "")
    @cost = ko.observable(if stats.cost? then stats.cost else "1m")
    @value = ko.observable(if stats.special?.value? then stats.special.value else "?")

class window.Ability
  constructor: (@type, @value) ->
