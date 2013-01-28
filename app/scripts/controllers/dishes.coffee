barbudosApp.controller 'DishesCtrl', ($scope, Dish, Category, cart) ->
    $scope.cart = cart
    $scope.dishes = Dish.query()

    $scope.categories = Category.query (categories) ->
        $scope.query = categories[0]._id if categories.length > 0

    $scope.$on 'cart-updated', (e,arg) ->
        $scope.cart = cart

    $scope.setQuery = (query) ->
        $scope.query = query

    $scope.submit = ->
        data = $scope.dish
        data.category = $scope.query

        dish = new Dish data

        dish.$save data, ->
            $scope.dishes.push dish
            $scope.dish = {}
    
    $scope.submitCategory = ->
        category = new Category $scope.category
        
        category.$save $scope.category, ->
            $scope.categories.push category
            $scope.category = {}
