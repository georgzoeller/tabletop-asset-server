###
    Task: Fetch Sources
    Purpose: Fetch files from a source into local cache
###

path = require 'path'

module.exports = (context, args) ->
  sources = [ ]

  context.config.sources.forEach (s) ->
    if Array.isArray s.source
      sources.push context.download.get source, s.kind || path.extname(source).substr(1), s.encoding, args for source in s.source
    else
      sources.push context.download.get s.source, args.kind || path.extname(s.source).substr(1), args.encoding, args

  await Promise.all sources

