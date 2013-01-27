'use strict';

angular.module('dishesServices', ['ngResource']).factory 'Dish', ['$resource', ($resource) ->
    $resource('/dishes/:dishId')
]
