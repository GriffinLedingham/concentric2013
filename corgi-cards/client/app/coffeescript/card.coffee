class window.Card
  constructor: (@delegate, data) ->
    {
      @socket
    } = @delegate

    @id = data.id
    @name = data.name

    @uname = data.uname

    @img = data.img

    @position = ko.observable [data.position.x, data.position.y]


  isMine: (card, ui) =>
    app.username() is @uname
