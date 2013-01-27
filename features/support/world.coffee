mongoose = require 'mongoose'
zombie = require 'zombie'
async = require 'async'
spawn = require('child_process').spawn
http = require 'http'


MONGOHQ_URL = 'mongodb://localhost/barbudos-test'


exports.World = (callback) ->
    browser = new zombie.Browser()
    db = mongoose.createConnection(MONGOHQ_URL).db

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


    env = PATH: process.env.PATH, MONGOHQ_URL: MONGOHQ_URL
    backend = spawn 'node_modules/.bin/coffee', ['barbudos.coffee'], env: env

    # callback when backend prints "Server listening port 3000"
    backend.stdout.once 'data', ->
        callback world

    process.on 'exit', ->
        backend.kill()
