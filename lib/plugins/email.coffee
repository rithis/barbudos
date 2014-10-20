# Email sender.
#
#     plugins = require "./lib/plugins"
#     container.set "admin email", "send@to.com"
#     container.set "email service", "GMAIL"
#     container.set "email user", "user@gmail.com"
#     container.set "email password", "password"
#
#     symfio = require "symfio"
#     container = symfio "example", __dirname
#     loader = container.get "loader"
#     loader.use plugins.email
nodemailer = require "nodemailer"
      

#### Must be configured:
#
# * __admin email__ - Send mail to.
# * __email service__ - Smtp service for send email.
# * __email host__ - Smtp server host address.
# * __email port__ - Smtp server port.
# * __email secure connection__ - Use SSL, default is false.
# * __email user__ - Username for service.
# * __email password__ - User password for auth.
module.exports = (container, callback) ->
  logger = container.get "logger"
  send = container.get "admin email"
  host = container.get "email host"
  port = container.get "email port"

  options =
    secureConnection: container.get "email secure connection" or false
    auth:
      user: container.get "email user"
      pass: container.get "email password"

  if host and port
    options.host = host
    options.port = port
  else
    options.service = container.get "email service"

  transport = nodemailer.createTransport "SMTP", options

  container.set "email", send: (subject, body) ->
    options = transport.options
    unless options.service or (host and port)
      logger.warn "transport not configured"
      return callback()

    unless options.auth.user and options.auth.pass
      logger.warn "auth for transport not configured"
      return callback()

    message =
      to: send
      subject: subject
      text: body

    transport.sendMail message, (err) ->
      logger.warn err if err

  callback()
