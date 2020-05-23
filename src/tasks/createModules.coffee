###
    Task: Create Modules
    Purpose: Create the initial module structure
###

fs = require 'fs-extra'


module.exports = (context, args) ->

    modulesConfig = context.config.modules

    Promise.all modulesConfig.map (module, args) ->
        context.modules[module.id] = {items: {}, dir: "#{process.cwd()}/#{context.config.contentRoot || 'content'}/#{module.id}"}
        await fs.ensureDir context.modules[module.id].dir






