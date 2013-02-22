barbudosApp.controller 'DishesCtrl', ($scope, Dish, cart) ->
    $scope.cart = cart
    $scope.dishes = Dish.query()

    $scope.$on 'cart-updated', (e,arg) ->
        $scope.cart = cart
