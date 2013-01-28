barbudosApp.controller 'CartCtrl', ($scope, cart, Order) ->
    $scope.cart = cart

    $scope.$on 'cart-updated', (e,arg) ->
        $scope.cart = cart
    
    $scope.submit = ->
        data = $scope.order
        data.cart = cart.id()
        
        order = new Order data

        order.$save data, ->
            cart.create()
            $scope.order = {}
