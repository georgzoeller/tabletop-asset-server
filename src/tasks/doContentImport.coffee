###
    Task: Start Server Task
    Purpose: Start the Webserver
###

Koa = require 'koa'
jwt = require 'koa-jwt'


module.exports = (context, args) ->

    await Promise.all context.config.sources.map (s) ->
      context.createTask(context, {title: s.name, args: s, type: s.type}).task()








