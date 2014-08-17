EventEmitter = require('events').EventEmitter
_ = require 'underscore'
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
    @name = options.name or 'copter' + Math.round(Math.random() * 1000)
    @type = options.type or 'hubsan_x4'
    @pin = options.pin or null
    @bound = false

  reset: ->
    @copterid = null
    @name = null
    @pin = null
    @bound = false

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

  requireConnected: ->
    if @isConnected()
      return true
    else
      @log.error('this drone is not connected')
      return false

  isBound: ->
    return @bound

  requireBound: ->
    if @isBound()
      return true
    else
      @log.error('this drone is not bound')
      return false

  pollUntilBound: (cb) ->
    pollFn = =>
      @getState (data) =>
        if data.result == 'success'
          if data.state == 'bound'
            @emit 'bind', @copterid
            @bound = true
            cb(data)
          else
            @log.info 'not bound yet, waiting...'
            setTimeout(pollFn, 3000)
        else
          @log.error 'error during binding'
          @emit 'exit'

    setTimeout(pollFn, 3000)

  bind: (cb = (->)) ->
    if @isBound()
      @log.error('this drone is already bound')
      @emit 'exit'
      return false

    @apiCall '/copter', 'bind', {name: @name, type: @type}, (data) =>
      if data.result == 'success'
        @copterid = data.copterid
        @emit 'init', data
        @pollUntilBound cb
      else
        cb(data)
    this

  getState: (cb = (->)) ->
    return if not @requireConnected()
    @sendCommand 'state', null, cb

  throttle: (value, cb = (->)) ->
    return if not @requireBound()
    @sendCommand 'throttle', value, cb

  rudder: (value, cb = (->)) ->
    return if not @requireBound()
    @sendCommand 'rudder', value, cb

  aileron: (value, cb = (->)) ->
    return if not @requireBound()
    @sendCommand 'aileron', value, cb

  elevator: (value, cb = (->)) ->
    return if not @requireBound()
    @sendCommand 'elevator', value, cb

  setFlip: (state, cb = (->)) ->
    return if not @requireBound()
    @sendCommand 'flip', state, cb

  setLed: (state, cb = (->)) ->
    return if not @requireBound()
    @sendCommand 'led', state, cb

  setVideo: (state, cb = (->)) ->
    return if not @requireBound()
    @sendCommand 'video', state, cb

  emergency: (cb = (->)) ->
    return if not @requireBound()
    @sendCommand 'emergency', null, cb

  disconnect: (cb = (->)) ->
    return if not @requireBound()
    @sendCommand 'disconnect', null, (data) =>
      if data.result == 'success'
        @emit 'disconnect', @copterid
        @reset()
      cb(data)
