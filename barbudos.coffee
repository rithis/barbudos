rithis = require "rithis-stack"
uuid = require "node-uuid"


rithis.configure __dirname, "barbudos", (stack, callback) ->
    # variables
    mongoose = stack.mongoose
    app = stack.app
    db = stack.connection

    # schemas
    CategorySchema = new mongoose.Schema
        name: type: "string", required: true

    DishSchema = new mongoose.Schema
        name: type: "string", required: true
        price: type: "number", required: true
        description: type: "string", required: true
        preview:
            type: "string",
            required: true,
            default: "http://lorempixel.com/300/300/food/1"
        category:
            type: mongoose.Schema.Types.ObjectId
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
            default: "http://lorempixel.com/300/300/food/1"
        count: type: "number", required: true

    CartSchema = new mongoose.Schema
        uuid: type: "string", required: true
        createdAt: type: Date, default: Date.now
        positions: [PositionSchema]

    OrderSchema = new mongoose.Schema
        cart: type: mongoose.Schema.Types.ObjectId, ref: "CartSchema"
        address: type: "string", required: true
        phone: type: "string", required: true

    # models
    Category = db.model "categories", CategorySchema
    Dish = db.model "dishes", DishSchema
    Position = db.model "positions", PositionSchema
    Cart = db.model "carts", CartSchema
    Order = db.model "orders", OrderSchema

    # actions
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

            Dish.findOne req.query.dish, (err, dish) ->
                if err
                    return req.send 500

                unless dish
                    return req.send 404

                position = dish.toObject()
                position.dish = req.query.dish
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
            
            data = req.query
            data.cart = cart._id
                
            order = new Order data
            order.save (err, order) ->
                if err
                    return res.send 500

                res.send order

    # routes
    app.get "/dishes", stack.crud
        .list(Dish)
        .make()
    app.post "/dishes", stack.crud
        .post(Dish)
        .make()
    
    app.get "/categories", stack.crud
        .list(Category)
        .make()
    app.post "/categories", stack.crud
        .post(Category)
        .make()

    app.get "/carts/:id", getCartAction
    app.post "/carts", postCartAction
    app.post "/carts/:id/positions", postCartPositionAction

    app.post "/orders", postOrderAction

    # done
    callback()
