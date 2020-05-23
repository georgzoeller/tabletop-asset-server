###
    Task: Start Pouchdb Server
    Purpose: Starts PouchDB server in background
###


open = require 'open'

module.exports = (context, args) ->

    argsObj = {}
    argsObj[k] = args[k] for k in ['app', 'wait'] when args[k]?

    await open(args.cmd, argsObj)




