mongoose = require 'mongoose'
zombie = require 'zombie'
async = require 'async'
spawn = require('child_process').spawn
exec = require('child_process').exec


MONGOHQ_URL = 'mongodb://localhost/barbudos-test'
env = PATH: process.env.PATH, MONGOHQ_URL: MONGOHQ_URL


exports.World = (callback) ->
    backend = null
    browser = null
    connection = null
    coffeelintSuccess = true

    world =
        spawnBackend: (callback) ->
            backend = spawn 'node_modules/.bin/coffee', ['barbudos.coffee'], env: env

            # callback when backend prints "Server listening port 3000"
            backend.stdout.once 'data', ->
                callback()

        killBackend: (callback) ->
            backend.kill()
            callback()

        initBrowser: (callback) ->
            browser = new zombie.Browser
            callback()

        visit: (url, callback) ->
            browser.visit url, callback

        checkPageContainsText: (text) ->
            (browser.html().indexOf text) >= 0

        createDatabaseConnection: (callback) ->
            connection = mongoose.createConnection(MONGOHQ_URL)
            
            # drop database after each connect
            connection.on 'open', ->
                connection.db.dropDatabase ->
                    callback()

        closeDatabaseConnection: (callback) ->
            connection.close ->
                callback()

        insert: (collection, documents, callback) ->
            connection.db.collection collection, (err, collection) ->
                task = (document, callback) ->
                    collection.insert document, safe: true, ->
                        callback()

                async.map documents, task, ->
                    callback()

        resetCoffeelintStatus: (callback) ->
            coffeelintSuccess = true
            callback()

        runCoffeelint: (path, callback) ->
            exec "node_modules/.bin/coffeelint -r #{path}", (error, output) ->
                if error
                    console.log output
                    coffeelintSuccess = false
                callback()

        isCoffeelintSuccess: (text) ->
            coffeelintSuccess

    callback world
