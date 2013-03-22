barbudosApp.controller "OrdersCtrl", ($scope, user, Order) ->
  $scope.orders = []
  $scope.groupedOrders = []
  $scope.statuses = [
    (name: "В ожидании", status: 0)
    (name: "Завершенные", status: 1)
  ]

  $scope.date =
    from: new Date new Date() - 2*60*60*24*1000
    to: new Date()

  $scope.change = (status) ->
    $scope.detail = false
    $scope.current = status
    params = status: status
    
    if status == 1
      params.from = $scope.date.from.toISOString()
      params.to = $scope.date.to.toISOString()

    groupByDate = (orders) ->
      results = []
      groupedByDate = {}
      orders.forEach (order) ->
        date = $.datepicker.formatDate "dd MM yy", new Date order.createdAt
        groupedByDate[date] = [] unless groupedByDate[date]
        groupedByDate[date].push order
      groupedByDate

    Order.query params, (orders) ->
      $scope.orders = orders if status == 0
      $scope.groupedOrders = groupByDate orders if status == 1

  $scope.change 0
