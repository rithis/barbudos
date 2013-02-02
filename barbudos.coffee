rithis = require 'rithis-stack'


rithis.configure __dirname, "barbudos", (app, db, callback) ->
    # schemas
    DishSchema = new rithis.Schema
        name: type: 'string', required: true
        price: type: 'number', required: true
        description: type: 'string', required: true

    # models
    Dish = db.model 'dishes', DishSchema

    # routes
    app.get '/dishes', rithis.crud
        .list(Dish)
        .make()
    app.post '/dishes', rithis.crud
        .post(Dish)
        .make()

    # done
    callback()
