libraries = ["Modernizr", "FTScroller", "ymaps"]

defineLibrary = (library) ->
    module = angular.module library, []
    module.factory library, ($window) ->
        $window[library]

for library in libraries
    defineLibrary library
