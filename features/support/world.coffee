mongoose = require 'mongoose'
connect = require 'connect'
zombie = require 'zombie'
async = require 'async'
fork = require('child_process').fork
exec = require('child_process').exec
http = require 'http'


MONGODB_URI = 'mongodb://localhost/barbudos-test'


exports.World = (callback) ->
    browser = new zombie.Browser()
    db = mongoose.createConnection(MONGODB_URI).db

    world =
        visit: (url, callback) ->
            browser.visit url, callback

        checkPageContainsText: (text) ->
            browser.html().indexOf text >= 0

        dropDatabase: (callback) ->
            db.dropDatabase ->
                callback()

        insert: (collection, documents, callback) ->
            db.collection collection, (err, collection) ->
                async.map documents, collection.insert.bind(collection), callback

    setup = [
        # build application
        (callback) ->
            exec 'yeoman build', ->
                callback()

        # spawn backend
        (callback) ->
            backend = fork 'backend', env: MONGODB_URI: MONGODB_URI
            
            process.on 'exit', ->
                backend.kill()

            # wait a second for setup
            setTimeout callback, 1000

        # serve application
        (callback) ->
            app = connect()
            app.use connect.static 'dist'

            server = http.createServer app
            server.listen 3501, ->
                callback()
    ]

    async.waterfall setup, ->
        callback world
