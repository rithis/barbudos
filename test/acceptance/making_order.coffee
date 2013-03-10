async = require "async"
test  = require "../support/test"
require "should"


describe "As a user who want to make order", ->
  wrapper = test.acceptance()

  before wrapper.loader()
  after wrapper.unloader()

  @timeout 5000

  it "I should see categories and dishes on main page",
    wrapper.wrap (callback) ->
      @visit "/", =>
        @getCategories().should.eql ["Блюда из мяса", "Напитки", "Десерты"]
        @getActiveCategory().should.eql "Блюда из мяса"
        @getDishes().should.eql ["Мясо"]
        callback()

  it "I should see dishes in other categories", wrapper.wrap (callback) ->
    @visit "/", =>
      @selectCategory "Напитки", =>
        @getDishes().should.eql ["Молоко"]

        @selectCategory "Десерты", =>
          @getDishes().should.eql ["Банан"]
          callback()

  it "I should be able to add dish to cart", wrapper.wrap (callback) ->
    @visit "/", =>
      @pageCotainsText("Что закажете?").should.be.true
      @getDishAmount("Мясо").should.eql "1"
      @addDishToCart "Мясо", =>
        @pageCotainsText("Что закажете?").should.be.false
        @pageCotainsText("1 блюд на 1000 руб.").should.be.true
        callback()

  it "I should see dishes added into cart after page is reloaded",
    wrapper.wrap (callback) ->
      @visit "/", =>
        @pageCotainsText("Что закажете?").should.be.false
        @pageCotainsText("1 блюд на 1000 руб.").should.be.true
        callback()

  it "I should be able to add many various dishes to cart",
    wrapper.wrap (callback) ->
      async.series [
        (callback) =>
          @visit "/", callback
        (callback) =>
          @setDishAmount "Мясо", 5, callback
        (callback) =>
          @addDishToCart "Мясо", callback
        (callback) =>
          @selectCategory "Напитки", callback
        (callback) =>
          @addDishToCart "Молоко", callback
        (callback) =>
          @pageCotainsText("6 блюд на 5100 руб.").should.be.true
          callback()
      ], callback

  it "I should be able to make order", wrapper.wrap (callback) ->
    @visit "/#!/cart", =>
      @location.hash.should.be.eql "#!/cart"
      @pageCotainsText("Мясо").should.be.true
      @makeOrder "Moscow", "+74956603920", =>
        @location.hash.should.be.eql "#!/"
        @pageCotainsText("Что закажете?").should.be.true
        callback()
