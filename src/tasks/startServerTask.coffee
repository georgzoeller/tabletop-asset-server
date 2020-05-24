###
    Task: Start Server Task
    Purpose: Start the Webserver
###

Koa = require 'koa'
jwt = require 'koa-jwt'
Router = require 'koa-router'
fs = require 'fs'



module.exports = (context, args) ->
    app = new Koa()
    app.context.runtime = context
    app.context.runtimeArgs = args
    router =  new Router()
    #app.use jwt { secret: process.env.TOKEN_SECRET }
    #router.get '/', (ctx) -> ctx.body = 'yay'

    router.get "/:type/:module/:id", require('../routes/singleAsset').get

    app.use router.routes()
    app.use router.allowedMethods()
    app.listen process.env.PORT

