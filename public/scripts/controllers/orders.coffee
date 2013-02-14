barbudosApp.controller 'OrdersCtrl', ($scope, Order) ->
    $scope.orders = Order.query()