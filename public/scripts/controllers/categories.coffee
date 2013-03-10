barbudosApp.controller "CategoriesCtrl", ($scope, $rootScope, Category) ->
  $scope.categories = Category.query (categories) ->
    if categories.length > 0
      $rootScope.category = $scope.active = categories[0]._id

  $scope.setActive = (active) ->
    $rootScope.category = $scope.active = active
