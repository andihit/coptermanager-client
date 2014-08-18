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

  isBound: ->
    return @bound

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
    @apiCall '/copter', 'bind', {name: @name, type: @type}, (data) =>
      if data.result == 'success'
        @copterid = data.copterid
        @emit 'init', data
        @pollUntilBound cb
      else
        cb(data)
    this

  getState: (cb = (->)) ->
    @sendCommand 'state', null, cb

  throttle: (value, cb = (->)) ->
    @sendCommand 'throttle', value, cb

  rudder: (value, cb = (->)) ->
    @sendCommand 'rudder', value, cb

  aileron: (value, cb = (->)) ->
    @sendCommand 'aileron', value, cb

  elevator: (value, cb = (->)) ->
    @sendCommand 'elevator', value, cb

  setFlip: (state, cb = (->)) ->
    @sendCommand 'flip', state, cb

  setLed: (state, cb = (->)) ->
    @sendCommand 'led', state, cb

  setVideo: (state, cb = (->)) ->
    @sendCommand 'video', state, cb

  emergency: (cb = (->)) ->
    @sendCommand 'emergency', null, cb

  disconnect: (cb = (->)) ->
    @sendCommand 'disconnect', null, (data) =>
      if data.result == 'success'
        @emit 'disconnect', @copterid
        @reset()
      cb(data)
