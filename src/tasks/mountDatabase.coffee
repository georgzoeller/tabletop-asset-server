###
    Task: createPouchDb
    Purpose: Persists content to pouchdb
###

debug = require('debug')('ts:mountPouchDb')
PouchDb = require 'pouchdb'



module.exports = (context, args) ->

  throw new Error("database location missing") if not args.location?
  throw new Error("database type missing") if not args.type?

  if args.type is 'pouch'
    Object.keys(context.modules).forEach (mid) ->
      module = context.modules[mid]
      location = "#{args.location}/#{mid}"
      # don't mess with disk if we are running in couchDb proxy mode
      module.db = new PouchDb(location)
  else
    throw new Error ("not implemented database type #{args.type}")
    ###tasks = []
    Object.keys(context.modules).forEach (mid) ->
      module = context.modules[mid]
      location = "#{args.location}/#{mid}"

      files = fs.readdir location

      files.map (f) ->
        new Promise (resolve, reject) ->
          module.collections[ yaml.safeLoad await fs.readFile "#{location}/#{f}", 'utf8'
    ###




















