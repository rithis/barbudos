dishesServices = angular.module 'dishesServices', ['ngResource']

dishesServices.factory 'Dish', ['$resource', ($resource) ->
    $resource '/dishes/:dishId'
]
