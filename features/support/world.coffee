coffeelint = require 'coffeelint'
mongoose = require 'mongoose'
zombie = require 'zombie'
async = require 'async'
spawn = require('child_process').spawn
exec = require('child_process').exec
glob = require 'glob'
fs = require 'fs'


MONGOHQ_URL = 'mongodb://localhost/barbudos-test'


exports.World = (callback) ->
    backend = null
    browser = null
    connection = null
    coffeelintErrors = []

    world =
        spawnBackend: (callback) ->
            backend = spawn 'node_modules/.bin/coffee', ['barbudos.coffee'],
                env: PATH: process.env.PATH, MONGOHQ_URL: MONGOHQ_URL

            # continue when backend prints "listening port 3000"
            backendOutput = ''
            backend.stdout.on 'data', (data) ->
                backendOutput += data
                if backendOutput.indexOf 'listening port 3000' >= 0
                    backend.stdout.removeAllListeners 'data'
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

        clearCoffeelintErrors: (callback) ->
            coffeelintErrors = []
            callback()

        runCoffeelint: (path, callback) ->
            lint = (files) ->
                task = (file, callback) ->
                    fs.readFile file, (error, data) ->
                        errors = coffeelint.lint data.toString(),
                            indentation: value: 4
                        
                        if errors.length > 0
                            coffeelintErrors.push [file, errors]
                        
                        callback()

                async.map files, task, ->
                    callback()

            unless /\.coffee$/.test path
                glob path + '/**/*.coffee', (error, files) ->
                    lint files
            else
                lint [path]

        getCoffeelintErrors: () ->
            coffeelintErrors

    callback world
