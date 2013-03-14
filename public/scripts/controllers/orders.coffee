barbudosApp.controller "OrdersCtrl", ($scope, user, Order) ->
  $scope.statuses = [
    (name: "В ожидании", status: 0)
    (name: "Завершенные", status: 1)
  ]

  $scope.date =
    from: new Date new Date() - 2*60*60*24*1000
    to: new Date()

  $scope.change = (status) ->
    $scope.current = status
    params = status: status
    
    if status == 1
      params.from = $scope.date.from.toISOString()
      params.to = $scope.date.to.toISOString()
    
    Order.query params, (orders) ->
      $scope.orders = orders
  
  $scope.change 0
