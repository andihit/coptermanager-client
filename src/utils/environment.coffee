isNode = typeof window == 'undefined'
isBrowser = not isNode

module.exports =
  isNode: isNode
  isBrowser: isBrowser
