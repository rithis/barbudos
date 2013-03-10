window.barbudosApp = angular.module "barbudosApp", [
  "dishesServices",
  "categoriesServices",
  "cartServices",
  "ordersServices",
  "userServices",
  "dishesDirective",
  "ordersDirective"
]


barbudosApp.config ($locationProvider) ->
  $locationProvider.hashPrefix "!"


barbudosApp.config ($routeProvider) ->
  $routeProvider.when "/",
    templateUrl: "views/dishes.html"
    controller: "DishesCtrl"

  $routeProvider.when "/cart",
    templateUrl: "views/cart.html"
    controller: "CartCtrl"

  $routeProvider.when "/about",
    templateUrl: "views/about.html"

  $routeProvider.when "/orders",
    templateUrl: "views/orders.html"
    controller: "OrdersCtrl"

  $routeProvider.when "/login",
    templateUrl: "views/login.html"
    controller: "LoginCtrl"

  $routeProvider.otherwise redirectTo: "/"


barbudosApp.config ($httpProvider) ->
  $httpProvider.responseInterceptors.push ($location, $cookieStore) ->
    (promise) ->
      success = (response) ->
        response

      error = (response) ->
        if response.status == 401
          $cookieStore.remove "token"
          $location.path "/login"
        response

      promise.then success, error
