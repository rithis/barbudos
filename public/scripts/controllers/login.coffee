barbudosApp.controller "LoginCtrl", ($scope, $location, user) ->
  $scope.user = {}
  $scope.invalid = false

  $scope.submit = ->
    return unless $scope.auth.$valid

    user.auth $scope.user.username, $scope.user.password, (auth) ->
      $scope.notify() unless auth
      $scope.invalid = not auth
      $location.url "/" if auth
