var connection,
    mongoose = require('mongoose'),
    util = require('util');


if (process.env.VCAP_SERVICES) {
    var env = JSON.parse(process.env.VCAP_SERVICES);
    var mongo = env['mongodb-1.8'][0]['credentials'];

    connection = mongoose.createConnection(util.format('mongodb://%s:%s@%s:%d/%s',
        mongo.username,
        mongo.password,
        mongo.hostname,
        mongo.port,
        mongo.db
    ))
} else {
    connection = mongoose.createConnection('mongodb://localhost/barbudos')
}


var DishSchema = new mongoose.Schema({
    name: {type: 'string', required: true},
    price: {type: 'number', required: true},
    description: {type: 'string', required: true}
});

var Dish = connection.model('dishes', DishSchema);


module.exports.connection = connection;
module.exports.Dish = Dish;
