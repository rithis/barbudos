module.exports = ->
    this.World = require('../support/world').World

    this.Given /^collection "([^"]*)":$/, (collection, documents, callback) ->
        this.insert collection, documents.hashes(), callback
