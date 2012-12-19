'use strict';

barbudosApp.controller('MockupAboutCtrl', function () {
    ymaps.ready(function () {
        var coords = [55.739868, 37.632844];

        var myMap = new ymaps.Map("map", {
            center: [coords[0] + .0013, coords[1] - .003],
            zoom: 16
        });

        myMap.geoObjects.add(new ymaps.Placemark(coords));
    });
});
