dishesDirective = angular.module "dishesDirective", ["Modernizr", "FTScroller", "ymaps"]

dishesDirective.directive "dishes", ($window, Modernizr, FTScroller) ->
    restrict: "A"
    link: (scope, element) ->
        calculation = false

        $window.onresize = ->
            if $window.outerWidth < 768
                unless calculation
                    length = element.children().length
                    children = element.children()[0]
                    width = children.offsetWidth
                    margins = children.offsetLeft * 2
                    calculation = length * (width + margins)

                element.css "width", "#{calculation}px"
            else
                element.css "width", "100%"

        if Modernizr.touch and not Modernizr.testAllProps("overflowScrolling")
            new FTScroller element.parent()[0], scrollbars: false

        $window.onresize()


dishesDirective.directive "amount", ->
    restrict: "A"
    scope: {}
    link: (scope, element, attrs) ->
        attrs.$observe "price", (price) ->
            scope.price = Number price
            scope.amount = 1

            scope.decrease = ->
                scope.amount -= 1

                if scope.amount < 1
                    scope.amount = 1

            scope.increase = ->
                scope.amount += 1

            scope.$watch "amount", ->
                scope.amountPrice = scope.amount * scope.price

                if not scope.amountPrice or scope.amountPrice < 0
                    scope.amountPrice = 0


dishesDirective.directive "map", (ymaps) ->
    restrict: "A"
    link: (scope, element, attributes) ->
        ymaps.ready ->
            coordinates = [Number(attributes.lat), Number(attributes.lon)]

            map = new ymaps.Map element[0],
                center: coordinates
                zoom: Number attributes.zoom

            placemark = new ymaps.Placemark coordinates
            
            map.geoObjects.add placemark
