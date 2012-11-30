module.exports.factory = function (port) {
    var controllers = require('./backend/controllers'),
        restify = require('restify'),
        models = require('./backend/models'),
        server = restify.createServer();

    models.connection.on('error', function () {
        server.close();
    });

    server.use(restify.bodyParser({ mapParams: false }));

    server.get('/dishes', controllers.list(models.Dish));
    server.post('/dishes', controllers.post(models.Dish));

    server.listen(port);
};
