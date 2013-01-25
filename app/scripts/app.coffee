'use strict';

barbudosApp = angular.module 'barbudosApp', ['dishesServices']

barbudosApp.config ['$httpProvider', ($httpProvider) ->
    delete $httpProvider.defaults.headers.common['X-Requested-With']
]

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