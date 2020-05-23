###
    Task: PersistContent
    Purpose: Persists content to selected form of storage
###

fs = require 'fs-extra'
yaml = require 'js-yaml'
debug = require('debug')('ts:persistContentToYaml')


module.exports = (context, args) ->


  for mid, module of context.modules
    debug "Persisting #{Object.keys(module.items).length} items from module #{mid} (#{module.dir})"

    skipped = 0
    wrote = 0
    failed = 0
    for id, item of module.items when item?
      file = "#{module.dir}/#{id}.yaml"

      if not args.overwriteExisting and fs.existsSync file
        skipped++
        continue

      try
        fs.writeFileSync file, yaml.safeDump item
        wrote++
      catch ex
        #console.error "Error: ", ex, item
        failed++

    debug "Wrote #{wrote}, Skipped #{skipped} (due to overwriteExisting = false) and Failed #{failed} files for #{mid} "









