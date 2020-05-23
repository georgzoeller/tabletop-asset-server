###
    Task: GenerateBattleMapTiledJson
    Purpose: Create a valid tiled JSON for use in tiled
###

fs = require 'fs-extra'

debug = require('debug')('ts: generateBattleMapTiledJson')

module.exports = (context, args) ->
    debug args
    module = context.modules[args.target]
    #file = "#{module.dir}/#{id}.yaml"
    #fs.writeFileSync

