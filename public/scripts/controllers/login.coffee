barbudosApp.controller 'LoginCtrl', ($scope, $location, user) ->
    $scope.user = {}

    $scope.submit = ->
        return unless $scope.auth.$valid
        
        user.auth $scope.user.username, $scope.user.password, (auth) ->
            $location.url '/' if auth
