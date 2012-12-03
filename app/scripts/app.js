'use strict';

var barbudosApp = angular.module('barbudosApp', ['dishesServices']);

barbudosApp.config(['$httpProvider', function($httpProvider) {
    delete $httpProvider.defaults.headers.common["X-Requested-With"];
}]);

barbudosApp.config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/', {
        templateUrl: 'views/dishes.html',
        controller: 'DishesCtrl'
    });

    $routeProvider.when('/mockup/index', {
        templateUrl: 'views/mockup/index.html'
    });

    $routeProvider.otherwise({
        redirectTo: '/'
    });
}]);
