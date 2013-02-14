barbudosApp.controller 'DishesCtrl', ($scope, Dish, cart) ->
    $scope.cart = cart
    $scope.dishes = Dish.query()

    $scope.$on 'cart-updated', (e,arg) ->
        $scope.cart = cart

    $scope.add = ->
        $scope.dishes.push new Dish
            name: 'Название'
            description: 'Описание'
            price: 0
            category: $scope.category
