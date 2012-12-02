#!/usr/bin/env node
var restify = require('restify'),
    mongoose = require('mongoose'),
    util = require('util');


// db
var db;
if (process.env.VCAP_SERVICES) {
    var env = JSON.parse(process.env.VCAP_SERVICES);
    var mongo = env['mongodb-1.8'][0]['credentials'];

    db = mongoose.createConnection(util.format('mongodb://%s:%s@%s:%d/%s',
        mongo.username,
        mongo.password,
        mongo.hostname,
        mongo.port,
        mongo.db
    ))
} else {
    db = mongoose.createConnection('mongodb://localhost/barbudos')
}


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
        (new Model(req.body)).save(function (err, document) {
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

server.use(restify.bodyParser({ mapParams: false }));
server.get('/dishes', listAction(Dish));
server.post('/dishes', postAction(Dish));

server.listen(process.env.VCAP_APP_PORT || 3000);

db.on('error', function () {
    server.close();
});
