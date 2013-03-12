barbudosApp.controller "DishesCtrl", ($scope, Dish, cart, user) ->
  $scope.dishes = Dish.query()
  $scope.cart   = cart
  $scope.user   = user

  $scope.dishesForSave = []

  $scope.$on "cart-updated", (err, arg) ->
    $scope.cart = cart

  $scope.add = ->
    dish = new Dish
      name: "Название"
      description: "Описание"
      price: 0
      size: 0
      preview: "/images/no-photo@2x.png"
      buyable: true
      category: $scope.category

    $scope.dishes.push dish
    $scope.dishesForSave.push dish

  $scope.saveAll = ->
    for dish in $scope.dishesForSave
      dish.$save()
    $scope.dishesForSave = []
