'use strict';

backendHostname = if window.location.hostname == 'localhost'    then 'http://localhost\\:3000'  else 'http://barbudos.eu01.aws.af.cm'

DEFAULT_METHODS =
    'get': method: 'JSONP', params: callback: 'JSON_CALLBACK', _method: 'GET'
    'query': method: 'JSONP', isArray: true, params: callback: 'JSON_CALLBACK', _method: 'GET'
    'save': method: 'JSONP', params: callback: 'JSON_CALLBACK', _method: 'POST'
    'remove': method: 'JSONP', params: callback: 'JSON_CALLBACK', _method: 'DELETE'
    'delete': method: 'JSONP', params: callback: 'JSON_CALLBACK', _method: 'DELETE'


angular.module('dishesServices', ['ngResource']).factory 'Dish', ['$resource', ($resource) ->
    $resource(backendHostname + '/dishes/:dishId', {}, DEFAULT_METHODS)
]