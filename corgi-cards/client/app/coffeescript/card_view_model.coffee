class window.CardViewModel
  constructor: (@delegate, data) ->
    {

    } = @delegate

    @card = data.card
    @position = ko.observable [data.position.x, data.position.y]


  dragstop: (ev, ui) =>
    @position()[0] = $(ui.target).css("top")
    @position()[1] = $(ui.target).css("left")

    socket.emit 'CardMoved', {x: ui.position.left, y: ui.position.top, card: @card}
