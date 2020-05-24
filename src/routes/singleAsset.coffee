
module.exports.get = (ctx, next) ->

    mod = ctx.params['module']
    assetType = ctx.params['type']
    id = ctx.params['id']
    runtime = ctx.runtime

    console.log ctx.params

    return ctx.status = 404 if not runtime.modules[mod]?

    # if we have the collections in memory we use that
    if runtime.modules[mod]?.collections[assetType]?

      asset = runtime.modules[mod].collections[assetType][id]
      if asset?
         ctx.body = asset
         ctx.status = 200
      else
        ctx.body = {error: "id not found" }
        ctx.status = 404
    # otherwise see if we have a database
    else if runtime.modules[mod].db?
      return runtime.modules[mod].db.get("#{assetType}-#{id}")
        .then (doc) ->
          ctx.body = doc
          ctx.status = 200
        .catch (err) ->
          ctx.body = err
          ctx.status = err.status

    else
      ctx.body = {error: 'No data ' + mod}
      ctx.status = 400














