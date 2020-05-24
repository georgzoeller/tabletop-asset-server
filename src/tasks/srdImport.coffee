###
    Task: SRD Import
    Purpose: Import records from the SRD
###

constants = require('../util/constants')
mout = require 'mout'
debug = require('debug')('ts:srdImport')



module.exports = (context, args) ->
  debug "Commencing srd import #{JSON.stringify args.name}"

  monsters = require "dnd5-srd/monsters"
  spells = require "dnd5-srd/spells"
  items = require "dnd5-srd/equipment"


  context.modules[args.target].collections.spells ?= {}
  context.modules[args.target].collections.monsters ?= {}
  context.modules[args.target].collections.items ?= {}
  spellCollection = context.modules[args.target].collections.spells
  monsterCollection = context.modules[args.target].collections.monsters
  itemCollection = context.modules[args.target].collections.items

  types = [[monsters,monsterCollection], [spells, spellCollection], [items, itemCollection]]


  debug "Importing #{monsters.length} monsters from SRD"
  for workItems in types
    for obj in workItems[0]
      target = workItems[1]

      obj.id = mout.string.slugify obj.name

      # Some monster specific fixes
      if target is monsterCollection
        for prop, val of constants.SRD_PROPS when obj[prop]
          obj[val]  = obj[prop]
          delete obj[prop]

        if obj.languages? and typeof obj.languages is 'string'
          obj.languages = obj.languages.split(',').map (e) -> e.trim?()

        obj.speed[k] = v.split(' ')[0] for k, v in obj.speed if obj.speed?
        obj.url = "/assets/monsters/#{obj.id}"

        delete p.url for p in obj.proficiencies when p.url?


      else if target is spellCollection
        obj.url = "/assets/spells/#{obj.id}"
      else if target is itemCollection
        obj.url = "/assets/items/#{obj.id}"

      if not target[obj.id]?
        #console.log "\t#{monster.id}: #{monster.name}"
        target[obj.id] = obj
      else
        console.warn "\tDuplicate ", obj.id







