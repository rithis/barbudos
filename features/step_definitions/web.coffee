module.exports = ->
    this.World = require('../support/world').World

    this.When /^I opened page "([^"]*)"$/, (uri, callback) ->
        this.visit "http://localhost:3000/#!#{uri}", callback

    this.Then /^I should see "([^"]*)" on the page$/, (text, callback) ->
        unless this.checkPageContainsText(text)
            callback.fail new Error "Page doesn't contains text '#{text}'"
        else
            callback()
