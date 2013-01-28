mongoose = require 'mongoose'
express = require 'express'
bower = require 'bower'
async = require 'async'
exec = require('child_process').exec
fs = require 'fs'
uuid = require 'node-uuid'
stylus = require('stylus')
nib = require('nib')


# pathes
__app = __dirname + '/app'
__component = __dirname + '/component.json'
__app_component = __app + '/component.json'


# database connection
connectionString = process.env.MONGOHQ_URL or 'mongodb://localhost/barbudos'
db = mongoose.createConnection connectionString


# models
CategorySchema = new mongoose.Schema
    name: type: 'string', required: true

Category = db.model 'categories', CategorySchema

DishSchema = new mongoose.Schema
    name: type: 'string', required: true
    price: type: 'number', required: true
    description: type: 'string', required: true
    preview:
        type: 'string',
        required: true,
        default: 'http://lorempixel.com/300/300/food/1'
    category:
        type: mongoose.Schema.Types.ObjectId
        ref: 'CategorySchema'
        required: true

Dish = db.model 'dishes', DishSchema

PositionSchema = new mongoose.Schema
    dish: type: mongoose.Schema.Types.ObjectId, ref: 'DishSchema'
    name: type: 'string', required: true
    price: type: 'number', required: true
    description: type: 'string', required: true
    preview:
        type: 'string',
        required: true,
        default: 'http://lorempixel.com/300/300/food/1'
    count: type: 'number', required: true

Position = db.model 'positions', PositionSchema

CartSchema = new mongoose.Schema
    uuid: type: 'string', required: true
    createdAt: type: Date, default: Date.now
    positions: [PositionSchema]

Cart = db.model 'carts', CartSchema

OrderSchema = new mongoose.Schema
    cart: type: mongoose.Schema.Types.ObjectId, ref: 'CartSchema'
    address: type: 'string', required: true
    phone: type: 'string', required: true

Order = db.model 'orders', OrderSchema


# CRUD
listAction = (Model) ->
    (req, res) ->
        Model.find (err, docs) ->
            res.send unless err then docs else 500

postAction = (Model) ->
    (req, res) ->
        doc = new Model req.body
        doc.save (err) ->
            res.send unless err then doc else 500

renderAction = (template) ->
    (req, res) ->
        res.render template

positionAction = (req, res, next) ->
    Cart.findOne uuid: req.params.id, (err, cart) ->
        unless cart
            req.send 404
            return next()

        if err
            req.send 500
            return next err

        exists = false
        cart.positions.forEach (item) ->
            if item.dish.toString() == req.query.dish
                exists = true
                if parseInt(req.query.count) > 0
                    item.count =  parseInt req.query.count
                else
                    cart.positions.remove item

        cartCallback = (err, document) ->
            if err
                req.send 500
                return next err
                
            res.send document
            next()

        unless exists
            return Dish.findOne req.query.dish, (err, dish) ->
                unless dish
                    req.send 404
                    return next()

                if err
                    req.send 500
                    return next err

                position = dish.toObject()
                position.dish = req.query.dish
                position.count = req.query.count
                delete position._id
                cart.positions.push position

                cart.save cartCallback

        cart.save cartCallback
                

cartAction = (req, res, next) ->
    Cart.findOne uuid: req.params.id, (err, cart) ->
        unless cart
            res.send 404

        res.send unless err then cart else 500

postCartAction = (req, res, next) ->
    new Cart(uuid: uuid.v1()).save (err, cart) ->
        if err
            return next err

        res.send cart
        next()

postOrderAction = (req, res, next) ->
    Cart.findOne uuid: req.query.cart, (err, cart) ->
        unless cart
            return res.send 404
        
        data = req.query
        data.cart = cart._id
            
        new Order(data).save (err, order) ->
            if err
                return next err
                
            res.send {}
            next()

# application
app = express()

compile = (str, path) ->
    stylus(str)
        .set('filename', path)
        .set('compress', false)
        .use(nib())
        .import('nib')

app.configure ->
    app.set 'views', __dirname + '/app'
    app.set 'view engine', 'jade'

    app.use express.logger()
    app.use express.json()
    
    app.use require('connect-coffee-script')
        src: __app
    
    app.use stylus.middleware
        src: __app
        compile: compile

    app.use express.static __app

app.configure 'development', ->
    app.use express.errorHandler()

app.get '/dishes', listAction Dish
app.post '/dishes', postAction Dish

app.get '/categories', listAction Category
app.post '/categories', postAction Category

app.get '/carts/:id', cartAction
app.post '/carts', postCartAction
app.post '/carts/:id/positions', positionAction

app.post '/orders', postOrderAction

app.get '/', renderAction 'index'
app.get '/views/dishes', renderAction 'views/dishes'
app.get '/views/cart', renderAction 'views/cart'
app.get '/views/mini-cart', renderAction 'views/mini-cart'

# startup
async.waterfall [
    (callback) ->
        fs.symlink __component, __app_component, ->
            callback()

    (callback) ->
        process.chdir __app
        bower.commands.install().on 'end', ->
            process.chdir __dirname
            callback()

    (callback) ->
        fs.unlink __app_component, ->
            callback()

    (callback) ->
        port = process.env.PORT or 3000
        app.listen port, ->
            console.log "Server listening port #{port}"
            callback()
]
