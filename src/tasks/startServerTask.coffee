###
    Task: Start Server Task
    Purpose: Start the Webserver
###

Koa = require 'koa'
jwt = require 'koa-jwt'


module.exports = (context, args) ->
    if process.argv.indexOf('listen') > -1
        app = new Koa()
        app.use jwt { secret: process.env.TOKEN_SECRET }
        app.use (ctx) -> ctx.body = 'Hello World'
        app.listen process.env.PORT

