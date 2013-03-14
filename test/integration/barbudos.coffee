test = require "../support/test"
require "should"


describe "barbudos", ->
  wrapper = test.integration()

  before wrapper.loader()
  after wrapper.unloader()

  describe "GET /dishes", ->
    it "should respond with dishes", wrapper.wrap (callback) ->
      req = @get "/dishes"
      req.end (err, res) ->
        res.should.have.status 200
        res.should.be.json
        res.body.should.be.array
        res.body.should.have.lengthOf 3
        res.body[0].name.should.equal "Мясо"
        res.body[1].name.should.equal "Молоко"
        res.body[2].name.should.equal "Банан"
        callback()

  describe "GET /categories", ->
    it "should respond with categories", wrapper.wrap (callback) ->
      req = @get "/categories"
      req.end (err, res) ->
        res.should.have.status 200
        res.should.be.json
        res.body.should.be.array
        res.body.should.have.lengthOf 3
        res.body[0].name.should.equal "Блюда из мяса"
        res.body[1].name.should.equal "Напитки"
        res.body[2].name.should.equal "Десерты"
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
        req = @get "/orders?status=0"
        req.set "Authorization", "Token token"
        req.end (err, res) ->
          res.should.have.status 200
          res.should.be.json
          res.body.should.be.array
          res.body.should.have.lengthOf 1
          res.body[0].address.should.equal "Moscow"
          res.body[0].phone.should.equal "+74956603920"
          callback()
