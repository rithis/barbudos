for library in ["Modernizr", "FTScroller", "ymaps"]
  do (library) ->
    module = angular.module library, []
    module.factory library, ($window) ->
      $window[library]
