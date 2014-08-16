EventEmitter = require('events').EventEmitter
_ = require 'underscore'
Log = require '../utils/log'
Environment = require '../utils/environment'

if Environment.isNode
  XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest
else
  XMLHttpRequest = window.XMLHttpRequest

module.exports = class WebClientDriver

  _.extend @prototype, EventEmitter.prototype

  constructor: (options = {}) ->
    if not options.endpoint
      throw 'please specify an endpoint in the options'

    @endpoint = options.endpoint
    @log = options.log

    @copterid = options.copterid or null
    @name = options.name or null
    @pin = options.pin or null

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
            @log.error "#{command}: #{data.error}"
          cb(data)
        else if xhr.status == 503
          @log.error "Network error. Please check your network. Is #{@endpoint} reachable?"
          @emit 'exit'
        else
          @log.error xhr.responseText
          @emit 'exit'

    xhr.send(JSON.stringify(data))

  sendCommand: (command, value = null, cb = (->)) ->
    data = {}
    data.value = value if value != null
    @apiCall "/copter/#{@copterid}/" + command, command, data, cb

  isConnected: ->
    return !!@copterid

  requireConnection: ->
    if @isConnected()
      return true
    else
      @log.error('this drone is not connected')
      return false

  bind: (type = 'hubsan_x4', options = {}, cb = (->)) ->
    if options.name
      @name = options.name
    else
      @name = 'copter' + Math.round(Math.random() * 1000)

    @apiCall '/copter', 'bind', {name: @name, type: type}, (data) =>
      if data.result == 'success'
        @copterid = data.copterid
        @emit 'bind', @copterid
      cb(data)
    this

  throttle: (value, cb = (->)) ->
    return if not @requireConnection()
    @sendCommand 'throttle', value, cb

  rudder: (value, cb = (->)) ->
    return if not @requireConnection()
    @sendCommand 'rudder', value, cb

  aileron: (value, cb = (->)) ->
    return if not @requireConnection()
    @sendCommand 'aileron', value, cb

  elevator: (value, cb = (->)) ->
    return if not @requireConnection()
    @sendCommand 'elevator', value, cb

  setFlip: (state, cb = (->)) ->
    return if not @requireConnection()
    @sendCommand 'flip', state, cb

  setLed: (state, cb = (->)) ->
    return if not @requireConnection()
    @sendCommand 'led', state, cb

  setVideo: (state, cb = (->)) ->
    return if not @requireConnection()
    @sendCommand 'video', state, cb

  emergency: (cb = (->)) ->
    return if not @requireConnection()
    @sendCommand 'emergency', null, cb

  disconnect: (cb = (->)) ->
    return if not @requireConnection()
    @sendCommand 'disconnect', null, (data) =>
      if data.result == 'success'
        @emit 'disconnect', @copterid
        @copterid = null
      cb(data)
