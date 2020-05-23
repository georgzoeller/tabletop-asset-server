###
    Task: Create Modules
    Purpose: Create the initial module structure
###

fs = require 'fs-extra'


module.exports = (context, args) ->

    modulesConfig = context.config.modules

    await fs.ensureDir './var/db'
    Promise.all modulesConfig.map (module, args) ->
        context.modules[module.id] = {name: module.name, collections:{}, dir: "#{process.cwd()}/#{context.config.contentRoot || 'content'}/#{module.id}"}
        await fs.ensureDir context.modules[module.id].dir






