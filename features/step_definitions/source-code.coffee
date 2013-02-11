module.exports = ->
    @World = require('../support/world').World

    @When /^I run coffeelint for "([^"]*)"$/, (path, callback) ->
        options =
            indentation: value: 4

        @runCoffeelint path, options, callback

    @When /^I run coffeelint for "([^"]*)" with line height "([^"]*)"$/, (path, lineLength, callback) ->
        options =
            indentation: value: 4
            max_line_length: value: lineLength

        @runCoffeelint path, options, callback

    @Then /^coffeelint should be success$/, (callback) ->
        coffeelintErrors = @getCoffeelintErrors()

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
