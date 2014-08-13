Client = require './client'
Environment = require '../utils/environment'

if Environment.isNode
  XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest
else
  XMLHttpRequest = window.XMLHttpRequest

module.exports = class WebClient extends Client

  constructor: (options) ->
    super
    if not options.endpoint
      throw 'please specify an endpoint in the options'
    @endpoint = options.endpoint

  apiCall: (path, command, data = {}, cb = (->)) ->
    xhr = new XMLHttpRequest()
    xhr.open('POST', @endpoint + path, true)
    xhr.setRequestHeader('Content-Type', 'application/json')
    xhr.setRequestHeader('Accept', 'application/json')
    xhr.onreadystatechange = =>
      if xhr.readyState == 4
        if xhr.status == 200
          data = JSON.parse(xhr.responseText)
          if data.result == 'error'
            @error command + ': ' + data.error
          cb(data)
        else if xhr.status == 503
          @error 'Network error. Please check your network. Is ' + @endpoint + ' reachable?'
          @exit()
        else
          @error xhr.responseText
          @exit()

    xhr.send(JSON.stringify(data))

  sendCommand: (command, value = null, cb = (->)) ->
    data = {}
    data.value = value if value
    @apiCall '/copter/' + @copterid + '/' + command, command, data


  bind: (name, type = 'hubsan_x4', cb = (->)) ->
    return if not super
    @apiCall '/copter', 'bind', {name: @name, type: type}, (data) =>
      if data.result == 'success'
        @copterid = data.uuid
        @emit 'bind', @copterid
      cb(data)
    this

  clockwise: (degrees, cb = (->)) ->
    return if not super
    @sendCommand 'rudder', degrees, cb
    this

  setFlip: (state, cb = (->)) ->
    return if not super
    @sendCommand 'flip', state, cb
    this

  setLed: (state, cb = (->)) ->
    return if not super
    @sendCommand 'led', state, cb
    this

  land: (cb = (->)) ->
    return if not super
    @sendCommand 'land', null, cb
    this

  emergency: (cb = (->)) ->
    return if not super
    @sendCommand 'emergency', null, cb
    this

  disconnect: (cb = (->)) ->
    return if not super
    @sendCommand 'disconnect', null, (data) ->
      if data.result == 'success'
        @emit 'disconnect', @copterid
        @copterid = null
      cb(data)
    this
