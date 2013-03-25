# Sms sender.
#
#     plugins = require "./lib/plugins"
#     container.set "sms auth email", "account email"
#     container.set "sms auth password", "account password"
#     container.set "sms status url", "http://example.com/sms_status_url"
#
#     symfio = require "symfio"
#     container = symfio "example", __dirname
#     loader = container.get "loader"
#     loader.use plugins.sms
request = require "superagent"
events  = require "events"
async   = require "async"
url     = require "url"
_       = require "lodash"

class Sms extends events.EventEmitter
  constructor: (@settings={}) ->
    
  send: (message, phones, cart) =>
    options = _.extend @settings,
      text: message

    options.dlr_url = "#{@settings.dlr_url}/#{cart}" \
      + "?status=%d&phone=%p" if @settings.dlr_url

    worker = (phone, callback) =>
      options.phone = phone

      request
        .post("http://api.sms24x7.ru/")
        .type("form")
        .send(options)
        .end (res) =>
          data = res.body.response.data
          msg = res.body.response.msg

          if msg.err_code == 0
            @emit "received",
              credits: data.credits
              parts: data.n_raw_sms
              smsId: data.id
              phone: phone
              cart: cart
          else
            @emit "error", msg.text
          
          callback()
    
    async.forEach phones, worker, =>
      @emit "complete"
      

#### Required plugins:
#
# * [__Express__](express.html).
# * [__Mongoose__](mongoose.html).
#
#### Can be configured:
#
# * __sms24x7 callback__ — Domain with url for send sms status.
#### Must be configured:
#
# * __sms24x7 username__ - Account email for login in sms24x7.ru.
# * __sms24x7 password__ - Account password for login in sms24x7.ru.
module.exports = (container, callback) ->
  connection = container.get "connection"
  statusUrl  = container.get "sms24x7 callback"
  mongoose   = container.get "mongoose"
  logger     = container.get "logger"
  app        = container.get "app"
  
  options    =
    password: container.get "sms24x7 password"
    method: "push_msg"
    format: "json"
    email: container.get "sms24x7 username"

  options.dlr_mask = 63 if statusUrl
  options.dlr_url  = statusUrl if statusUrl
  options.test     = true unless process.env.NODE_ENV == "production"

  SmsSchema = new mongoose.Schema
    smsId: type: "number", required: true
    status: type: "number"
    credits: type: "number", required: true
    parts: type: "number", required: true
    phone: type: "string", required: true
    cart: type: "string", required: true

  model = connection.model "sms", SmsSchema

  container.set "sms", create: ->
    return unless options.password and options.email

    sms = new Sms options
    sms.on "received", (data) ->
      (new model data).save()
    sms.on "error", (err) ->
      logger.warn err
    sms

  if statusUrl
    app.use (req, res, callback) ->
      pathname = "#{url.parse(statusUrl).pathname}/"
      status   = req.query.status
      phone    = req.query.phone

      return callback() unless req.url.indexOf(pathname) is 0
      return callback() unless status or phone

      cart = req._parsedUrl.pathname.replace(pathname, "")
      model.findOne cart: cart, phone: phone,
        (err, sms) ->
          res.send 500 if err or !sms

          sms.status = status
          sms.save ->
            res.send 200

  callback()
