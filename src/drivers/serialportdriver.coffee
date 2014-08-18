EventEmitter = require('events').EventEmitter
_ = require 'underscore'
SerialPort = require('serialport').SerialPort

PROTOCOL_CODES =
  COPTER_BIND:        0x01
  COPTER_THROTTLE:    0x02
  COPTER_RUDDER:      0x03
  COPTER_AILERON:     0x04
  COPTER_ELEVATOR:    0x05
  COPTER_LED:         0x06
  COPTER_FLIP:        0x07
  COPTER_VIDEO:       0x08
  COPTER_GETSTATE:    0x09
  COPTER_EMERGENCY:   0x0A
  COPTER_DISCONNECT:  0x0B
  COPTER_LISTCOPTERS: 0x0C

RESULT_CODES =
  PROTOCOL_OK: 0x00,
    
  PROTOCOL_UNBOUND: 0xE0
  PROTOCOL_BOUND: 0xE1
    
  PROTOCOL_INVALID_COPTER_TYPE: 0xF0
  PROTOCOL_ALL_SLOTS_FULL: 0xF1
  PROTOCOL_INVALID_SLOT: 0xF2
  PROTOCOL_VALUE_OUT_OF_RANGE: 0xF3
  PROTOCOL_EMERGENCY_MODE_ON: 0xF4
  PROTOCOL_UNKNOWN_COMMAND: 0xF5

COPTER_TYPES =
  HUBSAN_X4: 0x01

module.exports = class SerialPortDriver

  _.extend @prototype, EventEmitter.prototype

  constructor: (options = {}) ->
    if not options.serialport
      throw 'please specify a serial port in the options'

    @port = options.serialport
    @baudrate = options.baudrate or 115200
    
    @serialPort = null
    @log = options.log

    @copterid = options.copterid or null
    @type = options.type or COPTER_TYPES.HUBSAN_X4
    @bound = false

  reset: ->
    @serialPort = null
    @copterid = null
    @bound = false

  getErrorMessage: (resultCode) ->
    switch resultCode
      when RESULT_CODES.PROTOCOL_INVALID_COPTER_TYPE then 'invalid copter type'
      when RESULT_CODES.PROTOCOL_ALL_SLOTS_FULL then 'all slots are full'
      when RESULT_CODES.PROTOCOL_INVALID_SLOT then 'invalid slot'
      when RESULT_CODES.PROTOCOL_VALUE_OUT_OF_RANGE then 'value out of range'
      when RESULT_CODES.PROTOCOL_EMERGENCY_MODE_ON then 'emergency mode on'
      when RESULT_CODES.PROTOCOL_UNKNOWN_COMMAND then 'unknown command'
      else 'unknown error'

  _sendCommand: (command, commandcode, value, cb) ->
    copterid = @copterid or 0
    value = value or 0
    buffer = new Buffer([copterid, commandcode, value])

    @serialPort.once 'data', (data) =>
      resultCode = data[0]

      if resultCode >= 0xF0
        @log.error command + ': ' + @getErrorMessage(resultCode)
      cb(resultCode)

    @serialPort.write buffer, (error, results) =>
      if error
        @log.error "Serial port error: #{error}"
        @emit 'exit'

  sendCommand: (command, commandcode, value = 0, cb = (->)) ->
    if @serialPort
      return @_sendCommand(command, commandcode, value, cb)
    else
      @serialPort = new SerialPort @port, {baudrate: @baudrate}, true, (error) =>
        if error
          @log.error "Serial port error: #{error}"
          @emit 'exit'
        else
          # wait for arduino to boot
          setTimeout (=> @_sendCommand(command, commandcode, value, cb)), 1500

  isConnected: ->
    return !!@copterid

  isBound: ->
    return @bound

  pollUntilBound: (cb) ->
    pollFn = =>
      @getState (data) =>
        if data == RESULT_CODES.PROTOCOL_BOUND
          @emit 'bind', @copterid
          @bound = true
          cb(data)
        else if data == RESULT_CODES.PROTOCOL_UNBOUND
          @log.info 'not bound yet, waiting...'
          setTimeout(pollFn, 3000)
        else
          @log.error 'error during binding'
          @emit 'exit'

    setTimeout(pollFn, 3000)

  bind: (cb = (->)) ->
    @sendCommand 'bind', PROTOCOL_CODES.COPTER_BIND, @type, (data) =>
      if data < 0xF0
        @copterid = data
        @emit 'init', data
        @pollUntilBound cb
      else
        cb(data)
    this

  getState: (cb = (->)) ->
    @sendCommand 'getstate', PROTOCOL_CODES.COPTER_GETSTATE, null, cb

  throttle: (value, cb = (->)) ->
    @sendCommand 'throttle', PROTOCOL_CODES.COPTER_THROTTLE, value, cb

  rudder: (value, cb = (->)) ->
    @sendCommand 'rudder', PROTOCOL_CODES.COPTER_RUDDER, value, cb

  aileron: (value, cb = (->)) ->
    @sendCommand 'aileron', PROTOCOL_CODES.COPTER_AILERON, value, cb

  elevator: (value, cb = (->)) ->
    @sendCommand 'elevator', PROTOCOL_CODES.COPTER_ELEVATOR, value, cb

  setFlip: (state, cb = (->)) ->
    value = if state == 'on' then 1 else 0
    @sendCommand 'flip', PROTOCOL_CODES.COPTER_FLIP, value, cb

  setLed: (state, cb = (->)) ->
    value = if state == 'on' then 1 else 0
    @sendCommand 'led', PROTOCOL_CODES.COPTER_LED, value, cb

  setVideo: (state, cb = (->)) ->
    value = if state == 'on' then 1 else 0
    @sendCommand 'video', PROTOCOL_CODES.COPTER_VIDEO, value, cb

  emergency: (cb = (->)) ->
    @sendCommand 'emergency', PROTOCOL_CODES.COPTER_EMERGENCY, null, cb

  disconnect: (cb = (->)) ->
    @sendCommand 'disconnect', PROTOCOL_CODES.COPTER_DISCONNECT, null, (data) =>
      if data == RESULT_CODES.PROTOCOL_OK
        @emit 'disconnect', @copterid
        @serialPort.close()
        @reset()
      cb(data)
