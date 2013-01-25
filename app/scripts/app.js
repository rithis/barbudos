'use strict';

var barbudosApp = angular.module('barbudosApp', ['dishesServices']);

barbudosApp.config(['$httpProvider', function($httpProvider) {
    delete $httpProvider.defaults.headers.common["X-Requested-With"];
}]);

barbudosApp.config(['$locationProvider', function ($locationProvider) {
    $locationProvider.hashPrefix('!');
}]);

barbudosApp.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/', {
        templateUrl: 'views/dishes.html',
        controller: 'DishesCtrl'
    });

    $routeProvider.otherwise({
        redirectTo: '/'
    });
}]);
