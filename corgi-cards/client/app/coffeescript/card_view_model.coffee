class window.CardViewModel
  constructor: (@delegate, data) ->
    {

    } = @delegate

    @card = data.card
    @position = ko.observable [data.position.x, data.position.y]


  dragstop: (ev, ui) =>
    @position()[0] = $(ui.target).css("top")
    @position()[1] = $(ui.target).css("left")

    socket.emit 'CardMoved', =>
      {x: position[0], y: position[1], id: @card.card}
