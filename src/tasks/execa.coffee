###
    Task: Start Pouchdb Server
    Purpose: Starts PouchDB server in background
###


execa = require 'execa'

module.exports = (context, args) ->

    if args.action is 'exec'
        try
            module[args.handle] = execa(args.cmd, args.args)
            #module[args.handle].stdout.pipe(process.stdout) if module[args.handle]?
        catch ex
            console.error ex

    else if args.action is 'SIGTERM'
        module[args.handle].kill args.action, {forceKillAfterTimeout: 2000} if module[args.handle]?
    else if args.action is 'cancel'
        module[args.handle].cancel() if module[args.handle]?




