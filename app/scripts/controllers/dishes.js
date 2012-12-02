'use strict';

barbudosApp.controller('DishesCtrl', ['$scope', 'Dish', function ($scope, Dish) {
    $scope.dishes = Dish.query();

    $scope.submit = function () {
        var dish = new Dish($scope.dish);

        dish.$save(function () {
            $scope.dishes.push(dish);
            $scope.dish = {};
        });
    };
}]);
