module.exports.factory = function (port) {
    var compass = require('./compass'),
        connect = require('connect'),
        server = connect();

    compass.watch(__dirname, {
        css: 'frontend/styles',
        sass: 'frontend/styles'
    });

    server.use(connect.static(__dirname + '/frontend'));
    server.listen(port);
};
