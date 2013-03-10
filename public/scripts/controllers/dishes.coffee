barbudosApp.controller "DishesCtrl", ($scope, Dish, cart, user) ->
  $scope.dishes = Dish.query()
  $scope.cart   = cart
  $scope.user   = user

  $scope.$on "cart-updated", (err, arg) ->
    $scope.cart = cart

  $scope.add = ->
    $scope.dishes.push new Dish
      name: "Название"
      description: "Описание"
      price: 0
      size: 0
      buyable: true
      category: $scope.category
