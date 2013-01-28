mongoose = require 'mongoose'
express = require 'express'
bower = require 'bower'
async = require 'async'
exec = require('child_process').exec
fs = require 'fs'


# pathes
__app = __dirname + '/app'
__component = __dirname + '/component.json'
__app_component = __app + '/component.json'


# database connection
connectionString = process.env.MONGOHQ_URL or 'mongodb://localhost/barbudos'
db = mongoose.createConnection connectionString


# models
DishSchema = new mongoose.Schema
    name: type: 'string', required: true
    price: type: 'number', required: true
    description: type: 'string', required: true

Dish = db.model 'dishes', DishSchema


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


# application
app = express()

app.configure ->
    app.use express.logger()
    app.use express.json()
    
    app.use require('connect-coffee-script')
        src: __app
        bare: true
    
    app.use require('stylus').middleware
        src: __app

    app.use express.static __app

app.configure 'development', ->
    app.use express.errorHandler()

app.get '/dishes', listAction Dish
app.post '/dishes', postAction Dish


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
