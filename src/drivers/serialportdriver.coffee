EventEmitter = require('events').EventEmitter
_ = require 'underscore'
SerialPortClient = require('../serialport/serialportclient')
COPTER_TYPES = require('../serialport/protocol').COPTER_TYPES

SerialPortClientInstance = null
SerialPortClientOpened = false
ClientsCount = 0

module.exports = class SerialPortDriver

  _.extend @prototype, EventEmitter.prototype

  constructor: (options = {}) ->
    if not options.serialport
      throw 'please specify a serial port in the options'

    @serialport = options.serialport
    @baudrate = options.baudrate or 115200
    
    @log = options.log

    @copterid = null
    @bound = false

  reset: ->
    if ClientsCount == 0 and SerialPortClientInstance
      SerialPortClientInstance.close()
      SerialPortClientInstance = null
      SerialPortClientOpened = false

    @copterid = null
    @bound = false

  sendCommand: (command, value, cb) ->
    if SerialPortClientInstance
      if SerialPortClientOpened
        SerialPortClientInstance.sendCommand(@copterid or 0, command, value, cb)
      else
        setTimeout @sendCommand.bind(this, command, value, cb), 1000
    else
      SerialPortClientInstance = new SerialPortClient
      SerialPortClientInstance.open @serialport, @baudrate, (data) =>
        if data.result == 'error'
          @log.error data.error
          @emit 'exit'
        else
          # wait for arduino to boot
          setTimeout ( =>
            SerialPortClientOpened = true
            SerialPortClientInstance.sendCommand(@copterid or 0, command, value, cb)
          ), 1500

  isConnected: ->
    return !!@copterid

  isBound: ->
    return @bound

  pollUntilBound: (cb) ->
    pollFn = =>
      @getState (data) =>
        if data.state == 'bound'
          @emit 'bind', @copterid
          @bound = true
          cb(data)
        else if data.state == 'unbound'
          @log.info 'not bound yet, waiting...'
          setTimeout(pollFn, 3000)
        else
          @log.error "error during binding: #{data.error}"
          @emit 'exit'

    setTimeout(pollFn, 3000)

  bind: (type, cb) ->
    if arguments.length == 1
      cb = type
      type = null

    type = type or COPTER_TYPES.HUBSAN_X4
    cb = cb or (->)

    @sendCommand 'bind', type, (data) =>
      if data.result == 'success'
        @copterid = data.copterid
        @emit 'init', data
        ClientsCount++
        @pollUntilBound cb
      else
        cb(data)
    this

  
  throttle: (value, cb = (->)) -> @sendCommand 'throttle', value, cb
  rudder: (value, cb = (->)) -> @sendCommand 'rudder', value, cb
  aileron: (value, cb = (->)) -> @sendCommand 'aileron', value, cb
  elevator: (value, cb = (->)) -> @sendCommand 'elevator', value, cb
  setFlip: (state, cb = (->)) -> @sendCommand 'flip', state, cb
  setLed: (state, cb = (->)) -> @sendCommand 'led', state, cb
  setVideo: (state, cb = (->)) -> @sendCommand 'video', state, cb
  getState: (cb = (->)) -> @sendCommand 'getstate', 0, cb
  telemetry: (option, cb = (->)) -> @sendCommand 'telemetry', option, cb
  emergency: (cb = (->)) -> @sendCommand 'emergency', 0, cb

  disconnect: (cb = (->)) ->
    @sendCommand 'disconnect', 0, (data) =>
      if data.result == 'success'
        @emit 'disconnect', @copterid
        ClientsCount--
        @reset()
      cb(data)
