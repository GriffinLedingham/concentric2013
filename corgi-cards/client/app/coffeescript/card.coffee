class window.Card
  constructor: (@delegate, data) ->
    {
      @socket
    } = @delegate

    @id = data.id
    @name = data.name

    @type = data.type

    @uname = data.uname

    @img = data.img

    @position = ko.observable [data.position.x, data.position.y]


  isMine: (card, ui) =>
    console.log app.username(), @uname
    app.username() is @uname
