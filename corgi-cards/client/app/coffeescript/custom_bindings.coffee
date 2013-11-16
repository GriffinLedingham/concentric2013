ko.bindingHandlers.draggable =
    init: (element, valueAccessor) ->

      options = ko.utils.unwrapObservable(valueAccessor())
      element = $(element)

      $(element).draggable()
      $(element).on 'dragstop', options.dragstop