barbudosApp.controller 'DishesCtrl', ($scope, Dish, cart, user) ->
    $scope.cart = cart
    $scope.user = user
    $scope.dishes = Dish.query()

    $scope.$on 'cart-updated', (e,arg) ->
        $scope.cart = cart

    $scope.appliedClasses = (dish) ->
        "dishes-item-buyable" if dish.buyable

    $scope.add = ->
        $scope.dishes.push new Dish
            name: 'Название'
            description: 'Описание'
            price: 0
            size: 0
            category: $scope.category
