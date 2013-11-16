ko.bindingHandlers.draggable =
    init: (element, valueAccessor) ->

      options = ko.utils.unwrapObservable(valueAccessor())
      element = $(element)

      $(element).draggable()
      $(element).on 'drag', options.dragstop

ko.bindingHandlers.droppable =
    init: (element, valueAccessor) ->

      options = ko.utils.unwrapObservable(valueAccessor())
      element = $(element)

      $(element).droppable(options)