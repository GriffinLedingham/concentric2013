class window.Card
  constructor: (@delegate, data) ->
    {
      @socket
    } = @delegate

    @id = data.id
    @name = data.name

    @img = data.img

    @position = ko.observable [data.position.x, data.position.y]


  dragstop: (ev, ui) =>
    @position()[0] = $(ui.target).css("top")
    @position()[1] = $(ui.target).css("left")

    @socket.emit 'CardMoved', {id: @id, name: @name, x: ui.position.left, y: ui.position.top}
