module.exports =
  extractXmlText: (textNode) ->
    return textNode.map((n) -> n._text || '').join('\n') if Array.isArray textNode
    return textNode._text if textNode._text
    return textNode