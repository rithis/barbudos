'use strict';

var backendHostname = window.location.hostname == 'localhost'
    ? 'http://localhost\\:3000'
    : 'http://barbudos.eu01.aws.af.cm';

angular.module('dishesServices', ['ngResource']).factory('Dish', ['$resource', function ($resource) {
    return $resource(backendHostname + '/dishes/:dishId');
}]);
