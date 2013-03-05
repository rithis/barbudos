barbudosApp.controller 'CartCtrl', ($scope, $location, cart, Order) ->
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

            alert """
                Вы оформили заказ. Количество #{cart.count()}.
                Доставка на адресс #{order.address}.
                Контактный телефон #{order.phone}.
            """
            $location.url '/'
