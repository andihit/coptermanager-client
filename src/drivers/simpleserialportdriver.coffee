SerialPort = require('serialport').SerialPort
EventEmitter = require('events').EventEmitter
_ = require 'underscore'

module.exports = class SimpleSerialPortDriver

  _.extend @prototype, EventEmitter.prototype

  constructor: (options = {}) ->
    if not options.serialport
      throw 'please specify a serial port in the options'

    @port = options.serialport
    @baudrate = options.baudrate or 115200
    @receiveBuffer = ""
    
    @log = options.log

    @bound = false
    @reset()

  reset: ->
    @state =
      throttle: 0
      rudder: 0x7F
      aileron: 0x7F
      elevator: 0x7F

  dataReceived: (data) =>
    @receiveBuffer += data.toString()
    console.log @receiveBuffer
    lines = @receiveBuffer.split("\r\n")
    @receiveBuffer = lines.pop()

    for line in lines
      console.log line
      if line == 'Bound'
        @bound = true

  openSerialPort: (cb = (->)) ->
    @serialPort = new SerialPort @port, {baudrate: @baudrate}, true, (error) =>
      if error
        cb(result: 'error', error: "Serial port error: #{error}")
      else
        @serialPort.on 'data', @dataReceived
        cb(result: 'success')

  sendControlPacket: (cb = (->)) ->
    buffer = new Buffer([0x03, @state.throttle, @state.rudder, @state.aileron, @state.elevator])
    @serialPort.write buffer, (error, results) =>
      if error
        cb(result: 'error', error: "Serial port error: #{error}")
      else
        cb(result: 'success')

  sendSettingsPacket: (cmd, cb = (->)) ->
    buffer = new Buffer([0x04, cmd])
    @serialPort.write buffer, (error, results) =>
      if error
        cb(result: 'error', error: "Serial port error: #{error}")
      else
        cb(result: 'success')

  isConnected: ->
    return @bound

  isBound: ->
    return @bound

  pollUntilBound: (cb) ->
    pollFn = =>
      if @bound
        @emit 'bind'
        cb()
      else 
        @log.info 'not bound yet, waiting...'
        setTimeout(pollFn, 3000)

    setTimeout(pollFn, 1000)

  bind: (cb) ->
    @openSerialPort =>
      @pollUntilBound cb

  _rangeCheck: (value, min, max) ->
    if 0x00 <= value <= 0xFF
      return true
    else
      @log.info "value #{value} out of range (#{min} - #{max}), skipping..."
      return false

  throttle: (value, cb = (->)) ->
    return if not @_rangeCheck(value, 0x00, 0xFF)
    @state.throttle = value
    @sendControlPacket cb

  rudder: (value, cb = (->)) ->
    return if not @_rangeCheck(value, 0x34, 0xCC)
    @state.rudder = value
    @sendControlPacket cb

  aileron: (value, cb = (->)) ->
    return if not @_rangeCheck(value, 0x45, 0xC3)
    @state.aileron = value
    @sendControlPacket cb

  elevator: (value, cb = (->)) ->
    return if not @_rangeCheck(value, 0x3E, 0xBC)
    @state.elevator = value
    @sendControlPacket cb

  setFlip: (state, cb = (->)) ->
    @sendSettingsPacket (if state == 'on' then 0x07 else 0x08), cb

  setLed: (state, cb = (->)) ->
    @sendSettingsPacket (if state == 'on' then 0x05 else 0x06), cb

  setVideo: (state, cb = (->)) ->
    @log.info 'not implemented'

  getState: (cb = (->)) ->
    @log.info 'not implemented'

  telemetry: (option, cb = (->)) ->
    @log.info 'not implemented'

  emergency: (cb = (->)) ->
    @log.info 'not implemented'

  disconnect: (cb = (->)) ->
    @reset()
    @sendControlPacket =>
      @sendControlPacket =>
        setTimeout =>
          @serialPort.close()
          cb()
        , 2000
