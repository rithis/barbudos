container = require "../../barbudos"
supertest = require "supertest"
browser = require "./browser"
symfio = require "symfio"


class AbstractTest
    constructor: ->
        container.set "silent", true
        container.set "fixtures directory", "#{__dirname}/fixtures"
        container.set "connection string", "mongodb://localhost/test"
        container.set "unloader", symfio.unloader()

    loader: ->
        load = (callback) =>
            loader = container.get "loader"
            loader.load =>
                container.get("unloader").register (callback) =>
                    container.get("connection").db.dropDatabase ->
                        callback()

                @context = @createContext()
                callback()

        (callback) ->
            @timeout 100000
            load callback

    unloader: ->
        unload = (callback) =>
            unloader = container.get "unloader"
            unloader.unload callback

        (callback) ->
            @timeout 10000
            unload callback

    wrap: (test) ->
        (callback) =>
            test.call @context, callback

    createContext: ->
        {}


class IntegrationTest extends AbstractTest
    createContext: ->
        supertest container.get "app"


class AcceptanceTest extends AbstractTest
    createContext: ->
        browser site: "http://localhost:#{process.env.PORT or 3000}"


createIntegrationTestInstance = ->
    new IntegrationTest


createAcceptanceTestInstance = ->
    new AcceptanceTest


module.exports.integration = createIntegrationTestInstance
module.exports.acceptance = createAcceptanceTestInstance
