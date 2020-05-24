###
    Task: Tokenize
    Purpose: Detect and insert tokens such as dice rolling actions
###

XRegExp = require 'xRegExp'

diceRegex = /(\d+)?d(\d+)([\+\-]\d+)?/gi
toHitRegExp = /([\w\s]+):\s([\+\-][\d]+)\sto\shit/gi

escapeRegExp = (string) ->
  string.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&')


tokenize = (regExp, input, context, action = 'ROLL') ->
  line = "#{input}".replace(/\s\+\s/gim, '+').replace(/\s\-\s/gim, '-')
  found = line.match regExp

  found = new Set(found)
  if found?
    for item from found
      replacer = new RegExp(escapeRegExp item,'gi')
      if context?
        line = line.replace replacer, "{{#{action} #{item}|#{context}}}"
      else
        line = line.replace replacer, "{{#{action} #{item}}}"

  line

tokenizeToHit = (input, context) ->

  rxs = [toHitRegExp]

  for rx in rxs
    found = toHitRegExp.exec input
    if found?
      replacer = new RegExp(escapeRegExp found[0],'gi')
      input = input.replace replacer, "{{ATTACK #{found[0]}|roll|d20#{found[2]}|#{context} #{found[1]}}}"

  return input


module.exports = (context, args) ->

  for mid, module of context.modules
    for type, collection of module.collections
      for id, item of collection
        if type is 'monsters'
          for action in item.actions || []
            action.desc = tokenize diceRegex, action.desc, "#{item.name}'s #{action.name}", "DAMAGE"
            action.desc = tokenizeToHit action.desc, "#{item.name}'s #{action.name}"
          for action in item.legendary_actions || []
            action.desc = tokenize diceRegex, action.desc, "#{item.name}'s #{action.name}", "DAMAGE"
            action.desc = tokenizeToHit action.desc, "#{item.name}'s #{action.name}"

          item.hp = tokenize diceRegex, item.hp, "#{item.name}'s HP"
          item.hd = tokenize diceRegex, item.hd, "#{item.name}'s HP" if item.hd?









