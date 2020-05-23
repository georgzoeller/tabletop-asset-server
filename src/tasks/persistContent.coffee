###
    Task: PersistContent
    Purpose: Persists content to selected form of storage
###

fs = require 'fs-extra'
yaml = require 'js-yaml'
debug = require('debug')('ts:persistContent')


module.exports = (context, args) ->


  for mid, module of context.modules

    for type, collection of module.collections

      debug "Persisting #{Object.keys(module.collections[type]).length} #{type} from module #{mid} (#{module.dir})"

      skipped = 0
      wrote = 0
      failed = 0


      fs.ensureDirSync "#{module.dir}/#{type}"

      for id, item of collection
        file = "#{module.dir}/#{type}/#{id}.yaml"

        if not args.overwriteExisting and fs.existsSync file
          skipped++
          continue

        try
          fs.writeFileSync file, yaml.safeDump item
          wrote++
        catch ex
          #console.error "Error: ", ex, item
          failed++

      debug "#{type}: Wrote #{wrote}, Skipped #{skipped} (due to overwriteExisting = false) and Failed #{failed} files for #{mid} "




