symfio = require "symfio"
uuid   = require "node-uuid"

container = symfio "barbudos", __dirname
container.set "components", [
  "angular#~1.0",
  "angular-resource#~1.0",
  "angular-cookies#~1.0",
  "bootstrap#~2.1",
  "normalize-css#~2.1",
  "modernizr#~2.6",
  "ftscroller#~0.2",
  "jquery#~1.9",
  "jquery-ui#~1.9",
  "jquery-file-upload#~7.2",
  "semantic-grid",
  "select2#~3.3"
]

loader = container.get "loader"
loader.use symfio.plugins.express
loader.use symfio.plugins.expressLogger
loader.use symfio.plugins.assets
loader.use symfio.plugins.bower
loader.use symfio.plugins.mongoose
loader.use symfio.plugins.auth
loader.use symfio.plugins.uploads

loader.use (container, callback) ->
  connection = container.get "connection"
  mongoose = container.get "mongoose"

  CategorySchema = new mongoose.Schema
    _id: type: String
    name: type: "string", required: true

  DishSchema = new mongoose.Schema
    name: type: "string", required: true
    price: type: "number", required: true
    description: type: "string"
    size: type: "number", required: true
    sizeUnit:
      type: "string"
      required: true
      default: "гр"
      validate: (value) ->
        /гр|мл|шт|уп|см/i.test value
    preview:
      type: "string",
      required: true,
      default: "/images/no-photo@2x.png"
    buyable: type: Boolean, default: true
    category:
      type: String
      ref: "CategorySchema"
      required: true

  PositionSchema = new mongoose.Schema
    dish: type: mongoose.Schema.Types.ObjectId, ref: "DishSchema"
    name: type: "string", required: true
    price: type: "number", required: true
    description: type: "string", required: true
    preview:
      type: "string",
      required: true,
      default: '/images/no-photo@2x.png'
    category:
      type: mongoose.Schema.Types.ObjectId
      ref: 'CategorySchema'
      required: true
    count: type: 'number', required: true

  CartSchema = new mongoose.Schema
    uuid: type: "string", required: true
    createdAt: type: Date, default: Date.now
    positions: [PositionSchema]

  OrderSchema = new mongoose.Schema
    num: type: "number", unique: true, required: true
    cart: type: "string", required: true
    address: type: "string", required: true
    phone: type: "string", required: true
    createdAt: type: Date, default: Date.now
    positions: [PositionSchema]
    status:
      type: "number",
      required: true,
      default: 0
      validate: (value) ->
        [0,1].indexOf(value) >= 0

  Category = connection.model "categories", CategorySchema
  Position = connection.model "positions", PositionSchema
  Order    = connection.model "orders", OrderSchema
  Dish     = connection.model "dishes", DishSchema
  Cart     = connection.model "carts", CartSchema

  callback()

loader.use symfio.plugins.fixtures
loader.use symfio.plugins.crud

loader.use (container, callback) ->
  connection = container.get "connection"
  unloader   = container.get "unloader"
  crud       = container.get "crud"
  app        = container.get "app"

  Category = connection.model "categories"
  Position = connection.model "positions"
  Order    = connection.model "orders"
  Dish     = connection.model "dishes"
  Cart     = connection.model "carts"

  getCartAction = (req, res) ->
    Cart.findOne uuid: req.params.id, (err, cart) ->
      if err
        return res.send 500

      unless cart
        return res.send 404

      res.send cart

  postCartAction = (req, res) ->
    cart = new Cart uuid: uuid.v1()
    cart.save (err, cart) ->
      if err
        return res.send 500

      res.send cart

  postCartPositionAction = (req, res) ->
    Cart.findOne uuid: req.params.id, (err, cart) ->
      if err
        return req.send 500

      unless cart
        return req.send 404

      exists = false
      cart.positions.forEach (item) ->
        if item.dish.toString() == req.query.dish
          exists = true
          if Number(req.query.count) > 0
            item.count = Number req.query.count
          else
            cart.positions.remove item

      afterCartSaved = (err, doc) ->
        if err
          return req.send 500

        res.send doc

      if exists
        return cart.save afterCartSaved

      Dish.findOne _id: req.query.dish, (err, dish) ->
        if err
          return req.send 500

        unless dish
          return req.send 404

        position       = dish.toObject()
        position.dish  = req.query.dish
        position.count = req.query.count
        delete position._id
        cart.positions.push position

        cart.save afterCartSaved

  postOrderAction = (req, res) ->
    Cart.findOne uuid: req.query.cart, (err, cart) ->
      if err
        return res.send 500

      unless cart
        return res.send 404

      data           = req.query
      data.positions = cart.positions
      data.cart      = cart.uuid

      Order.count (err, count) ->
        return res.send 500 if err
        
        data.num = count + 1
        order = new Order data
        order.save (err, order) ->
          if err
            return res.send 500

          res.send order

  getOrderAction = (req, res) ->
    query = req.query
    params =
      status: query.status

    if query.from and query.to
      params.createdAt =
        "$gte": new Date query.from
        "$lt": new Date query.to

    Order.find params, (err, orders) ->
      return res.send 500 if err
      
      res.send orders

  isAuthenticated = (req,res,next) ->
    if req.user
      next()
    else
      res.send 401

  app.get "/dishes", crud.list(Dish).make()
  app.post "/dishes", crud.post(Dish).make()
  app.get "/dishes/:id", crud.get(Dish).make()
  app.post "/dishes/:id", crud.put(Dish).make()
  app.delete "/dishes/:id", isAuthenticated, crud.delete(Dish).make()

  app.get "/categories", crud.list(Category).make()
  app.post "/categories", crud.post(Category).make()

  app.get "/carts/:id", getCartAction
  app.post "/carts", postCartAction
  app.post "/carts/:id/positions", postCartPositionAction

  app.get "/orders", isAuthenticated, getOrderAction

  app.post "/orders", postOrderAction

  app.post "/orders/:id", isAuthenticated, crud.put(Order).make()

  callback()


loader.load() if require.main is module
module.exports = container
