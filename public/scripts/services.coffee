dishesServices = angular.module 'dishesServices', ['ngResource']
categoriesServices = angular.module 'categoriesServices', ['ngResource']
ordersServices = angular.module 'ordersServices', ['ngResource']
cartServices = angular.module 'cartServices', ['ngResource', 'ngCookies']

dishesServices.factory 'Dish', ['$resource', ($resource) ->
    $resource '/dishes/:dishId'
]

categoriesServices.factory 'Category', ['$resource', ($resource) ->
    $resource '/categories/:categoryId'
]

ordersServices.factory 'Order', ['$resource', ($resource) ->
    $resource '/orders/:orderId'
]

cartServices.factory 'cart', ($rootScope, $resource, $cookieStore) ->
    callback = (cart) ->
        $cookieStore.put 'cartId', cart.uuid
        $rootScope.cart = cart
        $rootScope.$broadcast 'cart-updated'
            
    create = ->
        Cart = $resource '/carts'
        (new Cart()).$save callback
        
    unless $cookieStore.get 'cartId'
        create()
    else
        params = id: $cookieStore.get 'cartId'
        $resource('/carts/:id').get params, callback, create

    create: create
    id: ->
        $rootScope.cart.uuid if $rootScope.cart
    all: ->
        if $rootScope.cart and $rootScope.cart.positions
            $rootScope.cart.positions
        else
            []
    has: (dish) ->
        exists = false
        angular.forEach @all(), (position) ->
            if position and position.dish == dish and position.count > 0
                exists = true
        exists
    get: (dish) ->
        position = false
        angular.forEach @all(), (item) ->
            if item.dish == dish
                position = item
        position
    add: (id, count) ->
        params =
            dish: id
            count: count
        Cart = $resource '/carts/:id/positions', id: $rootScope.cart.uuid

        (new Cart()).$save params, (cart) ->
            $rootScope.cart = cart
            $rootScope.$broadcast 'cart-updated'
    remove: (id) ->
        @add id, 0
    count: ->
        count = 0
        angular.forEach @all(), (position) ->
            count += position.count if position
        count
    price: ->
        price = 0
        angular.forEach @all(), (position) ->
            price += position.count * position.price
        price
