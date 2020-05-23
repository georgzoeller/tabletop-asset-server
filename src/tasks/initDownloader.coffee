###
    Task: Init Downloader
    Purpose: Initializes the downloader and cache manager that avoids unnecessary downloads by caching fetched files on disk
###

fs = require 'fs-extra'
bent = require 'bent'
convert = require 'xml-js'
debug = require('debug')('ts:downloader')

class CacheManager

  constructor: (@opts) ->
    debug "CacheManager initialized in #{@opts.directory || 'var/cache'}"
    fs.ensureDirSync @opts.directory

  hash: (value)->  require('crypto').createHash('sha1').update(value).digest('hex')

  get: (url, ext='json', encoding = 'string', args = {}) ->
    debug 'get', ext, encoding
    hash = @hash url
    file = "#{@opts.directory}/#{hash}.#{ext}"

    if not args.forceDownload and fs.existsSync file
      debug "from cache... #{url}"
      return Promise.resolve fs.readFileSync file, 'utf8'
    else
      debug "fetching... #{url}"
      loader = bent(encoding)
      try
        result = await loader url
        fs.writeFileSync  file, result, 'utf8'
      catch ex
        debug "ERROR:", "Failed to get #{url} - ", ex

      result

  xml: (url) ->
    xml = await @get url, 'xml'
    convert.xml2js xml, { alwaysArray: false, compact: true, nativeTypes: true, trim: true,  ignoreComment: true, spaces: 2 }




module.exports = (context, args ) ->
    context.download = new CacheManager(args)
