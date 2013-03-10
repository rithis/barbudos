dishesDirective = angular.module "dishesDirective", [
  "Modernizr"
  "FTScroller"
  "ymaps"
]


dishesDirective.directive "dishes", ($window, Modernizr, FTScroller) ->
  restrict: "A"
  link: (scope, element) ->
    calculation = false

    $window.onresize = ->
      if $window.outerWidth < 768
        unless calculation
          length      = element.children().length
          children    = element.children()[0]
          width       = children.offsetWidth
          margins     = children.offsetLeft * 2
          calculation = length * (width + margins)

        element.css "width", "#{calculation}px"
      else
        element.css "width", "100%"

    if Modernizr.touch and not Modernizr.testAllProps("overflowScrolling")
      new FTScroller element.parent()[0], scrollbars: false

    $window.onresize()


dishesDirective.directive "amount", (cart) ->
  restrict: "A"
  scope: {}
  link: (scope, element, attrs) ->
    dish = scope.$parent.dish
    attrs.$observe "price", (price) ->
      scope.price  = scope.$parent.dish.price
      scope.amount = dish.count or
        if cart.has(dish._id) then cart.get(dish._id).count else 1

      scope.add = ->
        cart.add dish._id, scope.amount

      scope.decrease = ->
        scope.amount -= 1

        if scope.amount < 1
          scope.amount = 1

      scope.increase = ->
        scope.amount += 1

      scope.$watch "amount", ->
        scope.amountPrice = scope.amount * scope.price

        if not scope.amountPrice or scope.amountPrice < 0
          scope.amountPrice = 0

        if dish.dish and cart.has(dish.dish)
          if cart.get(dish.dish).count != scope.amount
            cart.add dish.dish, scope.amount


dishesDirective.directive "map", (ymaps) ->
  restrict: "A"
  link: (scope, element, attributes) ->
    ymaps.ready ->
      coordinates = [Number(attributes.lat), Number(attributes.lon)]

      map = new ymaps.Map element[0],
        center: coordinates
        zoom: Number attributes.zoom

      placemark = new ymaps.Placemark coordinates
      
      map.geoObjects.add placemark


dishesDirective.directive "editable", ->
  restrict: "A"
  link: (scope, element, attrs) ->
    attrs.$set "contenteditable", "true"

    element.bind "keypress", (event) ->
      if event.keyCode == 13
        event.preventDefault()

      if attrs.numerable
        if event.keyCode < 48 or event.keyCode > 57
          event.preventDefault()


dishesDirective.directive "dish", (Dish) ->
  restrict: "A"
  link: (scope, element, attrs) ->
    scope.appliedClasses = ->
      classes = []

      if scope.dish.buyable and not scope.user.isAuthenticated()
        classes.push "dishes-item-buyable"

      unless scope.dish._id
        classes.push "dishes-item-new"

      classes.join " "

    unless scope.dish._id
      scope.create = ->
        dish = new Dish scope.dish
        dish.$save (dish) ->
          for key, value of dish
            scope.dish[key] = value


dishesDirective.directive "dishAutosave", ->
  restrict: "A"
  link: (scope, element, attrs) ->
    if element.is("input") and element.attr("type") is "checkbox"
      eventName = "change"
      getter = -> element.is ":checked"

    else if element.is "select"
      eventName = "change"
      getter = -> element.val()

    else if attrs.editable
      eventName = "blur"
      getter = -> element.text()

    element.on eventName, ->
      scope.dish[attrs.dishAutosave] = getter()

      if scope.dish._id
        scope.dish.$save dishId: scope.dish._id


dishesDirective.directive "fileupload", ($window, Dish) ->
  link: (scope, element) ->
    fileupload = $("<input type=\"file\">").fileupload
      url: "/uploads"
      paramName: "file"

    fileupload.bind "fileuploaddone", (event, data) ->
      scope.dish.preview = data.jqXHR.getResponseHeader "Location"
      scope.$apply()
      if scope.dish._id
        Dish.get dishId: scope.dish._id, (dish) ->
          dish.preview = scope.dish.preview
          dish.$save dishId: dish._id
      
    scope.add = ->
      fileupload.click()
