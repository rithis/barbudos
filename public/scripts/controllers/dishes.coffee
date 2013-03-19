barbudosApp.controller "DishesCtrl", ($scope, Dish, cart, user) ->
  $scope.dishes = Dish.query()
  $scope.cart   = cart
  $scope.user   = user

  $scope.dishesForSave = []

  $scope.$on "cart-updated", (err, arg) ->
    $scope.cart = cart

  $scope.add = ->
    dish = new Dish
      name: "Добавить название"
      description: "Добавить описание"
      price: "Цена"
      size: "Кол-во в порции"
      buyable: true
      category: $scope.category

    $scope.dishes.push dish
    $scope.dishesForSave.push dish

  $scope.delete = (dish) ->
    if dish._id
      return unless confirm "Вы уверены что хотите удалить?"
      dish.$delete dishId: dish._id
    else
      $scope.dishes.splice $scope.dishes.indexOf(dish), 1
      $scope.dishesForSave.splice $scope.dishesForSave.indexOf(dish), 1

  $scope.buyableOrder = (dish) ->
    not dish.buyable

  $scope.saveAll = ->
    for dish in $scope.dishesForSave
      dish.$save()
    $scope.dishesForSave = []
