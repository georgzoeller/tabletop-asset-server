###
    Task: Start Server Task
    Purpose: Start the Webserver
###

Koa       = require 'koa'
jwt       = require 'koa-jwt'
koaBody   = require "koa-body"
Router    = require 'koa-router'
cors      = require '@koa/cors'
compress  = require 'koa-compress'


module.exports = (context, args = {}) ->

  app = new Koa()
  router = new Router()

  app.context.runtime = context
  app.context.runtimeArgs = args

  args.jwt ?= {}
  args.jwt.revokedTokens ?= {}
  args.jwt.bannedUserIds = new Set(args.jwt.bannedUserIds || [] )

  isRevoked = (ctx, user, token) ->
    if args.jwt.revokedTokens[token]? or args.jwt.bannedUserIds.has user.uid
      console.warn "Rejected revoked credentials", user, token
      return Promise.resolve true
    Promise.resolve false

  app.use cors(args.cors || {})

  if process.env.TOKEN_SECRET?
    app.use jwt { secret: process.env.TOKEN_SECRET, isRevoked: isRevoked, debug: args.debug }
  else
    console.warn "Unsafe operation. process.env.TOKEN_SECRET is not set - everyone can read access the API."


  app.use compress( args.compress || {})
  app.use koaBody { multipart: true }

  router.get "/assets/:type/:module/:id", require('../routes/assets').get

  app.use router.routes()
  app.use router.allowedMethods()
  app.listen process.env.PORT
