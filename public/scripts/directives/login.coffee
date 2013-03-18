loginDirective = angular.module "loginDirective", []


loginDirective.directive "notify", ->
  restrict: "A"
  link: (scope, element) ->
    scope.notify = ->
      element.slideDown().delay(1500).slideUp()
