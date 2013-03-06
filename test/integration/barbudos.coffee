test = require "../support/test"
require "should"


describe "barbudos", ->
    wrapper = test.integration()

    before wrapper.loader()
    after wrapper.unloader()

    shouldInclude = (body, name) ->
        for item in body
            if item.name is name
                return
        throw new Error "expected #{body} should include #{name}"

    describe "GET /dishes", ->
        it "should respond with dishes", wrapper.wrap (callback) ->
            req = @get "/dishes"
            req.end (err, res) ->
                res.should.have.status 200
                res.should.be.json
                res.body.should.be.array
                res.body.should.have.lengthOf 3
                shouldInclude res.body, "Мясо"
                shouldInclude res.body, "Молоко"
                shouldInclude res.body, "Банан"
                callback()

    describe "GET /categories", ->
        it "should respond with categories", wrapper.wrap (callback) ->
            req = @get "/categories"
            req.end (err, res) ->
                res.should.have.status 200
                res.should.be.json
                res.body.should.be.array
                res.body.should.have.lengthOf 3
                shouldInclude res.body, "Блюда из мяса"
                shouldInclude res.body, "Напитки"
                shouldInclude res.body, "Десерты"
                callback()

    describe "GET /orders", ->
        it "should respond with 401 if token isn't provided",
            wrapper.wrap (callback) ->
                req = @get "/orders"
                req.end (err, res) ->
                    res.should.have.status 401
                    callback()

        it "should respond with orders if token is provided",
            wrapper.wrap (callback) ->
                req = @get "/orders"
                req.set "Authorization", "Token token"
                req.end (err, res) ->
                    res.should.have.status 200
                    res.should.be.json
                    res.body.should.be.array
                    res.body.should.have.lengthOf 1
                    res.body[0].address.should.equal "Moscow"
                    res.body[0].phone.should.equal "+74956603920"
                    callback()
