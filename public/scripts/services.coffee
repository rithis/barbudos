categoriesServices = angular.module "categoriesServices", ["ngResource"]
dishesServices     = angular.module "dishesServices", ["ngResource"]
ordersServices     = angular.module "ordersServices", ["ngResource"]
cartServices       = angular.module "cartServices", ["ngResource", "ngCookies"]
userServices       = angular.module "userServices", ["ngResource", "ngCookies"]


dishesServices.factory "Dish", ($resource) ->
  $resource "/dishes/:dishId"


categoriesServices.factory "Category", ($resource) ->
  $resource "/categories/:categoryId"


ordersServices.factory "Order", ($resource) ->
  $resource "/orders/:orderId"


cartServices.factory "Cart", ($resource) ->
  $resource "/carts/:cartId"


cartServices.factory "cart", ($rootScope, $resource, $cookieStore, $location) ->
  callback = (cart) ->
    $cookieStore.put "cartId", cart.uuid
    $rootScope.cart = cart
    $rootScope.$broadcast "cart-updated"
    $rootScope.location = $location

  create = ->
    Cart = $resource "/carts"
    (new Cart()).$save callback

  unless $cookieStore.get "cartId"
    create()
  else
    params = id: $cookieStore.get "cartId"
    $resource("/carts/:id").get params, callback, create

  create: create

  id: ->
    $rootScope.cart.uuid if $rootScope.cart

  all: ->
    if $rootScope.cart and $rootScope.cart.positions
      $rootScope.cart.positions
    else
      []

  has: (dish) ->
    exists = false
    angular.forEach @all(), (position) ->
      if position and position.dish == dish and position.count > 0
        exists = true
    exists

  get: (dish) ->
    position = false
    angular.forEach @all(), (item) ->
      if item.dish == dish
        position = item
    position

  add: (id, count) ->
    params =
      dish: id
      count: count
    Cart = $resource "/carts/:id/positions", id: $rootScope.cart.uuid

    (new Cart()).$save params, (cart) ->
      $rootScope.cart = cart
      $rootScope.$broadcast "cart-updated"

  remove: (id) ->
    @add id, 0

  count: ->
    count = 0
    angular.forEach @all(), (position) ->
      count += position.count if position
    count

  price: ->
    price = 0
    angular.forEach @all(), (position) ->
      price += position.count * position.price
    price


userServices.factory "user", ($resource, $http, $cookieStore) ->
  setToken = (token) ->
    $http.defaults.headers.common.Authorization = "Token #{token}"

  if $cookieStore.get "username" and $cookieStore.get "token"
    promise = $http.get("/sessions/#{$cookieStore.get "token"}")
    promise.success (data, status) ->
      setToken $cookieStore.get "token" if status is 200
      $cookieStore.remove "token" if status is 404

  isAuthenticated: ->
    $cookieStore.get("token")?

  getUsername: ->
    $cookieStore.get "username"

  logout: ->
    $cookieStore.remove "username"
    $cookieStore.remove "token"

  auth: (username, password, callback) ->
    body    = username: username, password: password
    promise = $http.post("/sessions", body)
    promise.success (auth, status) ->
      $cookieStore.put "username", username
      $cookieStore.put "token", auth.token if auth.token
      setToken auth.token
      callback(auth.token) if callback
