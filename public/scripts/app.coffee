window.barbudosApp = angular.module 'barbudosApp', ['dishesServices']

barbudosApp.config ['$locationProvider', ($locationProvider) ->
    $locationProvider.hashPrefix '!'
]

barbudosApp.config ['$routeProvider', ($routeProvider) ->
    $routeProvider.when '/',
        templateUrl: 'views/dishes.html'
        controller: 'DishesCtrl'
        
    $routeProvider.otherwise
        redirectTo: '/'
]
