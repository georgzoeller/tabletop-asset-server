###
    Task: XML Import Item
    Purpose: Import an item in XML format
###

constants = require('../util/constants')
xmlHelper = require '../util/xmlHelper'
mout = require 'mout'

debug = require('debug')('ts:xmlImportItem')


itemDescFunction = (v, obj) ->
  return '' if not v?
  s = ""
  if Array.isArray v
    s = v.map((c)->
      if c._text?
        return xmlHelper.extractXmlText c
      else
        return ""
        ).join '\n'
  s

safeParseInt = (v) ->
  result = parseInt v
  return result if not isNaN result
  0


determineTargetField = (k, map) ->
  return map[k] if map[k]?
  k


idFunction = (v, obj) ->
  mout.string.slugify v

convertFormat = (obj, template, map) ->

  ret = {}
  for k, v of template
    field =  determineTargetField k, map

    if v is null
      ret[k] = obj[field]||''
    else if typeof v is 'string'
      ret[k]  = "#{obj[field]||''}"
    else if typeof v is 'function'
      ret[k]  = v(obj[field], obj)
    else if Array.isArray v
      if not obj[field]?
        ret[k] = []
      else if typeof obj[field] is 'string'
        ret[k]  = obj[field].split(',').map (e) -> e.trim?()||e
      else if Array.isArray obj[field]
        ret[k] = obj[field]
    else if typeof v is 'object' and obj[field]?
      ret[k] = v[obj[field].toUpperCase?()|| obj[field]]

  ret


# -- These are the properties generated on the target object

ITEM_TEMPLATE  =
  name: ''
  desc: itemDescFunction
  id: idFunction
  weight: parseFloat
  magic: safeParseInt
  rarity: ''
  cost: null
  range: ''

# -- These are used to map properties to the accepted output format
XML_MAP_ITEM={
  id: 'name'
  desc: 'text'
  cost: 'value'
}


module.exports = (context, args) ->
    debug "Commencing XML item import from #{JSON.stringify args.name}"


    xml = args.source
    json = await context.download.xml xml

    if not context.modules[args.target]?
      console.error "Invalid target module #{args.target} on job #{args.name}"
      return

    context.modules[args.target].collections.items ?= {}
    target = context.modules[args.target].collections.items

    newObj = 0
    patched = 0
    duplicates = 0
    for item in json.compendium.item
      item[k] = v._text for k, v of item when v._text?
      result =  convertFormat item, ITEM_TEMPLATE, XML_MAP_ITEM

      if not result.id?
        throw new Error("Invalid ID generated on item")

      if not target[result.id]?
        newObj++
        #console.log "\t#{result.id}: #{result.name}"
        target[result.id] = result

      else
        didPatch = false
        patch = target[result.id]
        for k, v of result when patch[k]?

          if result[k]?
            #console.warn "diff", result[k], patch[k] if result[k] != patch[k] and typeof[k] isnt 'object'
            continue

          didPatch = true
          patch[k] = result[k]
        if didPatch
          patched++
        else
          duplicates++

    debug "#{args.name} yielded #{newObj} new items and augmented #{patched} existing items with aditional data. #{duplicates} duplicates were ignored."

