###
    Task: createPouchDb
    Purpose: Persists content to pouchdb
###

fs = require 'fs-extra'
debug = require('debug')('ts:createPouchDb')
PouchDb = require 'pouchdb'




module.exports = (context, args) ->


  Object.keys(context.modules).forEach (mid) ->
    module = context.modules[mid]

    location = "#{args.location}/#{mid}"
    # don't mess with disk if we are running in couchDb proxy mode
    if args.location.indexOf('http') == -1
      fs.ensureDirSync location


    module.db = new PouchDb(location)


    if not module.db?
      console.error ("Could not open db")
      process.exit()
      return

    Object.keys(module.collections).forEach (type) ->
      collection = module.collections[type]
      debug "Persisting #{Object.keys(module.collections[type]).length} #{type} from module #{mid} (#{module.dir})"

      stop = false

      tasks = Object.keys(collection).map (id) ->
        item = collection[id]
        item._id = "#{type}-#{id}"

        new Promise (resolve, reject) ->
          try
            resolve() if stop
            if args.overwriteExisting?
              doc = await module.db.get(item._id)
              item._rev = doc._rev
            resolve await module.db.put item
          catch err
            if err.name is 'not_found'
              if args.overwriteExisting?
                resolve await module.db.put item
              else
                resolve item
            else
              console.error err
              stop = true
              resolve()



      await Promise.all tasks







