
route = 'monsters'
module.exports.get = (ctx, next) ->


    mod = ctx.params['module']
    assetType = ctx.params['type']
    id = ctx.params['id']
    runtime = ctx.runtime


    return ctx.status = 404 if not runtime.modules[mod]?

    # if we have the collections in memory we use that
    if runtime.modules[mod]?.collections[route]?

      monster = runtime.modules[mod].collections[route][id]
      if monster?
         ctx.body = monster
         ctx.status = 200
      else
        ctx.body = {error: "id not found" }
        ctx.status = 404
    # otherwise see if we have a database
    else if runtime.modules[mod].db?
      return runtime.modules[mod].db.get("#{route}-#{id}")
        .then (doc) ->
          ctx.body = doc
          ctx.status = 200
        .catch (err) ->
          ctx.body = err
          ctx.status = err.status

    else
      ctx.body = {error: 'No data ' + mod}
      ctx.status = 400














