ordersDirective = angular.module "ordersDirective", []

ordersDirective.directive "order", (Cart) ->
  restrict: "A"
  scope: {}
  link: (scope, element, attrs) ->
    scope.detail = false
    scope.order  = scope.$parent.order
    
    scope.toggleDetail = ->
      scope.detail = !scope.detail
      if scope.detail and !scope.cart
        Cart.get cartId: scope.order.cart, (cart) ->
          scope.cart = cart

    scope.changeStatus = (status, $event) ->
      $event.stopPropagation()
      scope.order.status = status
      scope.order.$save orderId: scope.order._id
