###
    Task: XML Import Spell
    Purpose: Import a spell in XML format
###

constants = require('../util/constants')
xmlHelper = require '../util/xmlHelper'
mout = require 'mout'

debug = require('debug')('ts:xmlImportSpell')


spellDescFunction = (v, obj) ->
  s = xmlHelper.extractXmlText v
  idx  = s.indexOf 'At Higher Levels: '
  s = s.substr(0, idx-1) if idx > -1
  s


higherLevelFunction = (v, obj) ->
  s = xmlHelper.extractXmlText v
  idx  = s.indexOf 'At Higher Levels: '
  if idx > -1
    s = s.substr(idx)
  else
    s = null
  s

classFunction = (v, obj) ->
  ret = []
  if typeof v is 'string'
    ret.push {name: cls.trim(), url: "/api/classes/#{encodeURIComponent cls.trim()}"} for cls in v.split(', ')
  else if Array.isArray v
    ret = v.map (c) -> name: c.trim(), url: "/api/classes/#{encodeURIComponent c.trim()}"
  ret

componentFunction = (v, obj) ->
  return [] if not v?
  if typeof v is 'string'
    v.split(',').map (c) -> c.trim()
  else if typeof v is 'object'
    return Object.values v



cleanSpellNameFunction = (v, obj) ->
  v = v.replace(' (EE)', '')
  v = v.replace(' (PHB)', '')
  v = v.replace(' (SCAG)', '')
  v = v.replace(' (UA)', '')
  v

schoolFunction = (v, obj) ->
  ret = []
  if typeof v is 'string'
    ret.push {name: constants.SCHOOL_PROPS[cls.trim()], url: "/api/schools/#{encodeURIComponent constants.SCHOOL_PROPS[cls.trim()]}"} for cls in v.split(', ')
  else if Array.isArray v
    ret = v.map (c) -> name: constants.SCHOOL_PROPS[c.trim()], url: "/api/schools/#{encodeURIComponent  constants.SCHOOL_PROPS[c.trim()]}"
  ret


spellIdFunction = (v, obj) ->
  v  =  cleanSpellNameFunction(v)
  mout.string.slugify v


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
SPELL_TEMPLATE  =
  name: cleanSpellNameFunction
  higher_level: higherLevelFunction
  desc: spellDescFunction
  id: spellIdFunction
  school: schoolFunction
  classes: classFunction
  duration: xmlHelper.extractXmlText
  casting_time: ''
  level: parseInt
  components: componentFunction
  range: ''

# -- These are used to map properties to the accepted output format
XML_MAP_SPELL=
  higher_level: 'text'
  desc: 'text'
  id: 'name'
  casting_time: 'time'



module.exports = (context, args) ->
    debug "Commencing XML spell import from #{JSON.stringify args.name}"


    xml = args.source
    json = await context.download.xml xml

    if not context.modules[args.target]?
      console.error "Invalid target module #{args.target} on job #{args.name}"
      return

    context.modules[args.target].collections.spells ?= {}
    target = context.modules[args.target].collections.spells

    newObj = 0
    patched = 0
    duplicates = 0
    for spell in json.compendium.spell
      spell[k] = v._text for k, v of spell when v._text?
      result =  convertFormat spell, SPELL_TEMPLATE, XML_MAP_SPELL

      if not result.id?
        throw new Error("Invalid ID generated on spell")

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

    debug "#{args.name} yielded #{newObj} new spells and augmented #{patched} existing spells with aditional data. #{duplicates} duplicates were ignored."

