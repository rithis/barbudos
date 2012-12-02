'use strict';

describe('Controller: DishesCtrl', function () {
    var $httpBackend,
        DishesCtrl,
        scope;

    beforeEach(module('barbudosApp'));

    beforeEach(inject(function ($injector) {
        $httpBackend = $injector.get('$httpBackend');
        $httpBackend.when('GET', 'http://localhost:3000/dishes').respond([
            {
                name: "Fake Dish",
                price: .99,
                description: "Some description"
            }
        ]);
    }));

    beforeEach(inject(function ($controller) {
        scope = {};
        DishesCtrl = $controller('DishesCtrl', {
            $scope: scope
        });
        $httpBackend.flush();
    }));

    it('should attach a list of dishes to the scope', function () {
        expect(scope.dishes.length).toBe(1);
    });

    it('should send new dish to server', function () {
        scope.dish = {
            name: "New Dish",
            price: 1.99,
            description: "asd"
        };
        $httpBackend.expect('POST', 'http://localhost:3000/dishes', scope.dish).respond();
        scope.submit();
        $httpBackend.flush();
        expect(scope.dish.name).toBeUndefined();
        expect(scope.dish.price).toBeUndefined();
        expect(scope.dish.description).toBeUndefined();
    });
});
