###
    Task: Start Server Task
    Purpose: Start the Webserver
###

Koa = require 'koa'
jwt = require 'koa-jwt'


module.exports = (context, args) ->

  sources = []

  context.config.modules.forEach (module) ->

    sources = module.sources.map (s) ->
      argsObj = JSON.parse JSON.stringify s
      argsObj.target = module.id
      context.createTask(context, {title: s.name, args: argsObj, type: s.type}).task()

  await Promise.all sources








