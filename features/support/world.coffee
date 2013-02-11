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

        reload: (callback) ->
            browser.reload callback

        toCategory: (category, callback) ->
            browser.clickLink category, callback

        clickDishButton: (dish, button, callback) ->
            block = @getDishBlock dish
            button = browser.query('input[value="В корзину"]', block)
            button.focus()
            browser.fire 'click', button, callback

        checkPageContainsText: (text) ->
            (browser.html().indexOf text) >= 0
            
        cartIsEmpty: ->
            browser.query('a[href="#!/cart"]').textContent == 0
        
        checkPageContainsDish: (name, description, price) ->
            unless title = browser.query("h2:contains(#{name})")
                return false
            
            unless title.nextSibling.textContent == description
                return false

            unless title.nextSibling.nextSibling.textContent == "#{price} руб."
                return false

            return true
        
        checkPageCategoriesOrder: (categories) ->
            exists = []
            query = '*[data-ng-repeat="category in categories"] > a'
            for category in browser.queryAll(query) then do (category) ->
                exists.push category.textContent

            return categories.join() == exists.join()

        categoryIsActive: (category) ->
            query = 'li.active[data-ng-repeat="category in categories"] > a'
            active = browser.query query
            active and active.textContent == category

        dishExists: (dish) ->
            browser.query("h2:contains(#{dish})")

        dishAmountIs: (dish, amount) ->
            block = @getDishBlock dish
            browser.query('input[type="text"]', block).value == amount

        pageTitleIs: (title) ->
            browser.text("title") == title

        getDishBlock: (dish) ->
            browser.query("h2:contains(#{dish})").parentNode

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

        runCoffeelint: (path, options, callback) ->
            lint = (files) ->
                task = (file, callback) ->
                    fs.readFile file, (error, data) ->
                        errors = coffeelint.lint data.toString(), options
                        
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
