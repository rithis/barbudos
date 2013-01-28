module.exports = ->
    this.World = require('../support/world').World

    this.When /^I run coffeelint for "([^"]*)"$/, (path, callback) ->
        this.runCoffeelint path, callback

    this.Then /^coffeelint should be success$/, (callback) ->
        coffeelintErrors = this.getCoffeelintErrors()

        if coffeelintErrors.length == 0
            return callback()

        message = "Coffeelint failed\n"

        for lint in coffeelintErrors
            file = lint[0]
            errors = lint[1]
            message += "  file #{file}\n"

            for error in errors
                message += "    line #{error.lineNumber}: #{error.message}\n"
                
                if error.context
                    message += "      #{error.context}\n"

            message += "\n"

        callback.fail message
