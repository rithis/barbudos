window.barbudosApp = angular.module 'barbudosApp', [
    'dishesServices',
    'categoriesServices',
    'cartServices',
    'ordersServices',
    'dishesDirective'
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
        
    $routeProvider.otherwise
        redirectTo: '/'
]
