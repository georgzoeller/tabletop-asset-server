###
    Task: Create Modules
    Purpose: Create the initial module structure
###

fs = require 'fs-extra'


module.exports = (context, args) ->

    process.nextTick ->
        console.log "\t-------------------------------------"
        Object.keys(context.modules).forEach (mid) ->
            module = context.modules[mid]
            console.log "\t#{module.name}:"
            Object.keys(module.collections).forEach (key) -> console.log '\t\t', Object.keys(module.collections[key]).length, ' ', key
        console.log "\t-------------------------------------"






