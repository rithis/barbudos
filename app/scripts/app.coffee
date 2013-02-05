window.barbudosApp = angular.module 'barbudosApp', [
    'dishesServices',
    'categoriesServices',
    'cartServices',
    'ordersServices'
]

barbudosApp.config ['$locationProvider', ($locationProvider) ->
    $locationProvider.hashPrefix '!'
]

barbudosApp.config ['$routeProvider', ($routeProvider) ->
    $routeProvider.when '/',
        templateUrl: 'views/dishes'
        controller: 'DishesCtrl'
    
    $routeProvider.when '/cart',
        templateUrl: 'views/cart'
        controller: 'CartCtrl'
        
    $routeProvider.otherwise
        redirectTo: '/'
]
