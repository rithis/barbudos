ordersDirective = angular.module "ordersDirective", []

ordersDirective.directive "order", (Cart) ->
  restrict: "A"
  scope: {}
  link: (scope, element, attrs) ->
    scope.detail = false
    scope.order  = scope.$parent.order

    scope.changeStatus = (status) ->
      scope.order.status = status
      scope.order.$save orderId: scope.order._id
      
    scope.fullPrice = (positions) ->
      price = 0
      positions.forEach (position) ->
        price += position.price
      price

ordersDirective.directive "datepicker", (Cart, $parse) ->
  restrict: "A"
  scope: {}
  link: (scope, element, attrs) ->
    ngModel = $parse attrs.ngModel
    $ ->
      element.datepicker
        inline: true
        dateFormat: "dd MM yy"
        onSelect: (dateText, inst) ->
          scope.$apply (scope) ->
            ngModel.assign scope.$parent, element.datepicker "getDate"
            scope.$parent.change scope.$parent.current

    element.next().on "click", -> element.datepicker "show"
