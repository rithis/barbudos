#!/usr/bin/env node
var restify = require('restify'),
    mongoose = require('mongoose'),
    util = require('util');
var methodOverride = require('./restify-method-override'),
    cors = require('./restify-method-override');


// db
var connectionString;
if (process.env.VCAP_SERVICES) {
    var env = JSON.parse(process.env.VCAP_SERVICES);
    var mongo = env['mongodb-1.8'][0]['credentials'];

    connectionString = util.format(
        'mongodb://%s:%s@%s:%d/%s',
        mongo.username,
        mongo.password,
        mongo.hostname,
        mongo.port,
        mongo.db
    );
} else if (process.env.MONGODB_URI) {
    connectionString = process.env.MONGODB_URI;
} else {
    connectionString = 'mongodb://localhost/barbudos';
}
var db = mongoose.createConnection(connectionString);


// models
var DishSchema = new mongoose.Schema({
    name: {type: 'string', required: true},
    price: {type: 'number', required: true},
    description: {type: 'string', required: true}
});

var Dish = db.model('dishes', DishSchema);


// crud
var listAction = function (Model) {
    return function (req, res, next) {
        Model.find(function (err, documents) {
            if (err) {
                return next(err);
            }

            res.send(documents);
            return next();
        });
    };
};

var postAction = function (Model) {
    return function (req, res, next) {
        (new Model(req.query)).save(function (err, document) {
            if (err) {
                return next(err);
            }

            res.send(document);
            return next();
        });
    }
};


// server
var server = restify.createServer();

server.pre(methodOverride());
server.use(restify.bodyParser({ mapParams: false }));
server.use(restify.jsonp());
server.use(cors(['http://bar-barbudos.ru', 'http://barbudos.rithis.com', 'http://localhost:3501']));

server.opts(/^/, function (req, res, next) {
    res.send(200);
    next();
});

server.get('/dishes', listAction(Dish));
server.post('/dishes', postAction(Dish));

server.listen(process.env.VCAP_APP_PORT || 3000);

db.on('error', function () {
    server.close();
});
