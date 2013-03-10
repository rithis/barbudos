barbudosApp.controller "OrdersCtrl", ($scope, user, Order) ->
  $scope.orders = Order.query()
