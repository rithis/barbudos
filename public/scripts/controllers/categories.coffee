barbudosApp.controller 'CategoriesCtrl', ($scope, $rootScope, Category) ->
    $scope.categories = Category.query (categories) ->
        $rootScope.category = $scope.active = categories[0]._id if categories.length > 0
    
    $scope.setActive = (active) ->
        $rootScope.category = $scope.active = active