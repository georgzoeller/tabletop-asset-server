###
    Task: XML Import Monster
    Purpose: Import a monster in XML format
###

constants = require('../util/constants')
xmlHelper = require '../util/xmlHelper'
mout = require 'mout'

debug = require('debug')('ts:xmlMonsterImport')

actionFunction = (v, obj) ->
  return [] if not v?
  return [ {name: v.name._text, desc: xmlHelper.extractXmlText v.text} ] if typeof v is 'object' and not Array.isArray v
  ret = []
  for entry in v
    name = entry.name._text || xmlHelper.extractXmlText(entry.text).split(' ')[0]
    ret.push {name: name, desc: xmlHelper.extractXmlText entry.text, name}

  ret

traitFunction = (v, obj) ->
  return [] if not v?
  return [ {name: v.name._text, desc: xmlHelper.extractXmlText v.text} ] if typeof v is 'object' and not Array.isArray v
  ret = []
  ret.push {name: entry.name._text || xmlHelper.extractXmlText(entry.text).split(' ')[0], desc: xmlHelper.extractXmlText entry.text} for entry in v
  ret

senseFunction = (v, obj) ->
  ret = {}

  if v?
    if Array.isArray v
      for senseString in v
        [sense, value...] = senseString.split(' ')
        ret[sense] = value.join(' ')
    else if typeof v is 'string'
      [sense, value...] = v.split(' ')
      ret[sense] = value.join(' ')


  ret.passive_perception = obj.passive if obj.passive
  ret

idFunction = (v, obj) ->
  mout.string.slugify v

speedFunction = (v, obj) ->
  {walk: v}


componentFunction = (v, obj) ->
  return [] if not v?
  if typeof v is 'string'
    v.split(',').map (c) -> c.trim()
  else if typeof v is 'object'
    return Object.values v

conditionImmunitiesFunction = (v, obj) ->
  return [] if not v?
  if typeof v is 'string'
    return v.split(',').map (c) -> name: c.trim(), url: "/api/conditions/#{encodeURIComponent c.trim()}"
  else if Array.isArray v
    return v.map (c) -> name: c.trim(), url: "/api/conditions/#{encodeURIComponent c.trim()}"
  else if typeof v is 'object'
    return Object.keys(v).map (c) -> name: c.trim(), url: "/api/conditions/#{encodeURIComponent c.trim()}"




determineTargetField = (k, map) ->
  return map[k] if map[k]?
  k

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
MONSTER_TEMPLATE = {
  id: idFunction
  size: constants.SIZE_PROPS
  type: ''
  alignment: ''
  name: ''
  str: parseInt
  dex: parseInt
  con: parseInt
  wis: parseInt
  int: parseInt
  hp: ''
  hd: ''
  cha: parseInt
  ac: parseInt
  cr: parseInt
  senses: senseFunction
  actions: actionFunction
  special_abilities: traitFunction
  languages: []
  speed: speedFunction
  damage_vulnerabilities: componentFunction
  damage_resistances: componentFunction
  damage_immunities: componentFunction
  condition_immunities: conditionImmunitiesFunction
}

# -- These are used to map properties to the accepted output format
XML_MAP_MONSTER = {
  special_abilities: 'trait'
  actions: 'action'
  id: 'name'
  condition_immunities: 'conditionImmune'
  damage_resistances: 'resist'
  damage_immunities: 'immune'
  damage_vulnerabilities: 'vulnerable'
}


module.exports = (context, args) ->
    debug "Commencing XML monster import from #{JSON.stringify args.name}"


    xml = args.source
    json = await context.download.xml xml

    if not context.modules[args.target]?
      console.error "Invalid target module #{args.target} on job #{args.name}"
      return

    context.modules[args.target].collections.monsters ?= {}
    target = context.modules[args.target].collections.monsters

    newObj = 0
    patched = 0
    duplicates = 0
    for monster in json.compendium.monster
      monster[k] = v._text for k, v of monster when v._text?
      result =  convertFormat monster, MONSTER_TEMPLATE, XML_MAP_MONSTER

      if not result.id?
        throw new Error("Invalid ID generated on monster")

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

    debug "#{args.name} yielded #{newObj} new objects and augmented #{patched} existing objects with aditional data. #{duplicates} duplicates were ignored."

