'use strict';

backendHostname = if window.location.hostname == 'localhost'    then 'http://localhost\\:3000'  else 'http://barbudos.eu01.aws.af.cm'

angular.module('dishesServices', ['ngResource']).factory 'Dish', ['$resource', ($resource) ->
    $resource(backendHostname + '/dishes/:dishId')
]