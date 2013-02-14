window.barbudosApp = angular.module 'barbudosApp', [
    'dishesServices',
    'categoriesServices',
    'cartServices',
    'ordersServices',
    'dishesDirective',
    'ordersDirective'
]

barbudosApp.config ['$locationProvider', ($locationProvider) ->
    $locationProvider.hashPrefix '!'
]

barbudosApp.config ['$routeProvider', ($routeProvider) ->
    $routeProvider.when '/',
        templateUrl: 'views/dishes.html'
        controller: 'DishesCtrl'
    
    $routeProvider.when '/cart',
        templateUrl: 'views/cart.html'
        controller: 'CartCtrl'

    $routeProvider.when '/about',
        templateUrl: 'views/about.html'

    $routeProvider.when '/orders',
        templateUrl: 'views/orders.html'
        controller: 'OrdersCtrl'
        
    $routeProvider.otherwise
        redirectTo: '/'
]
