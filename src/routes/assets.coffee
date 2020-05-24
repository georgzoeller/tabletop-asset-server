
statblocks = require '../util/statblock'

module.exports.get = (ctx, next) ->

    mod = ctx.params['module']
    assetType = ctx.params['type']
    id = ctx.params['id']
    runtime = ctx.runtime

    console.log ctx.params, ctx.query

    return ctx.status = 404 if not runtime.modules[mod]?

    # if we have the collections in memory we use that
    if runtime.modules[mod]?.collections[assetType]?

      asset = runtime.modules[mod].collections[assetType][id]
      if asset?

        if ctx.query?.statblock is 'true' and statblocks[assetType]?
          ctx.body = statblocks[assetType]?(asset)
          ctx.type = ctx.type = ' text/html; charset=UTF-8'
        else
          ctx.body = asset
        ctx.status = 200
      else
        ctx.body = {error: "id not found" }
        ctx.status = 404
    # otherwise see if we have a database
    else if runtime.modules[mod].db?
      return runtime.modules[mod].db.get("#{assetType}-#{id}")
        .then (doc) ->
          if ctx.query?.statblock is 'true' and statblocks[assetType]?
            ctx.type = 'text/html; charset=UTF-8'
            ctx.body = statblocks[assetType]?(doc)
          else
            ctx.body = doc
          ctx.status = 200
        .catch (err) ->
          ctx.body = err
          ctx.status = 500
          console.error err

    else
      ctx.body = {error: 'No data ' + mod}
      ctx.status = 400















