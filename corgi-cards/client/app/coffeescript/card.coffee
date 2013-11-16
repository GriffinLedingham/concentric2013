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


  isMine: (card, ui) =>
    app.username() is @uname
