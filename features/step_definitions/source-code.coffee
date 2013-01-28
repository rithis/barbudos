module.exports = ->
    this.World = require('../support/world').World

    this.When /^I run coffeelint for "([^"]*)"$/, (path, callback) ->
        this.runCoffeelint path, callback

    this.Then /^coffeelint should be success$/, (callback) ->
        unless this.isCoffeelintSuccess()
            callback.fail new Error "Coffeelint failed"
        else
            callback()
