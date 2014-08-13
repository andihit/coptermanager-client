SerialPort = require('serialport').SerialPort
Client = require './client'

PROTOCOL_CODES =
  COPTER_BIND:       0x01
  COPTER_THROTTLE:   0x02
  COPTER_RUDDER:     0x03
  COPTER_AILERON:    0x04
  COPTER_ELEVATOR:   0x05
  COPTER_LED:        0x06
  COPTER_FLIP:       0x07
  COPTER_VIDEO:      0x08
  COPTER_LAND:       0x09
  COPTER_EMERGENCY:  0x0A
  COPTER_DISCONNECT: 0x0B

COPTER_TYPES =
  HUBSAN_X4: 0x01

module.exports = class SerialPortClient extends Client

  constructor: (options) ->
    super
    if not options.port
      throw 'please specify the serial port in the options'
    if not options.baudrate
      throw 'please specify the baud rate in the options'

     @serialPort = new SerialPort options.port, baudrate: 115200

  sendCommand: (command, value = 0, cb = (->)) ->
    to_send = new Buffer(3)
    to_send.writeUInt8(@copterid or 0, 0)
    to_send.writeUInt8(command, 1)
    to_send.writeUInt8(value, 2)

    @serialPort.write to_send, (err, results) =>
      console.log('err ' + err)
      console.log('results ' + results)

      @serialPort.once "data", (data) ->
        console.log("got data: "+data)
        if data < 0
          console.log("error")
        else
          cb(data)


  bind: (name, type = COPTER_TYPES.HUBSAN_X4, cb = (->)) ->
    return if not super
    @sendCommand PROTOCOL_CODES.COPTER_BIND, type, (copterid) ->
      if copterid > 0
        @copterid = copterid
      cb(copterid)
    this

  clockwise: (degrees, cb = (->)) ->
    return if not super
    @sendCommand PROTOCOL_CODES.COPTER_RUDDER, degrees, cb
    this

  setFlip: (state, cb = (->)) ->
    return if not super
    @sendCommand PROTOCOL_CODES.COPTER_FLIP, state == 'on' ? 0x01 : 0x00, cb
    this

  setLed: (state, cb = (->)) ->
    return if not super
    @sendCommand PROTOCOL_CODES.COPTER_LED, state == 'on' ? 0x01 : 0x00, cb
    this

  land: (cb = (->)) ->
    return if not super
    @sendCommand PROTOCOL_CODES.COPTER_LAND, null, cb
    this

  emergency: (cb = (->)) ->
    return if not super
    @sendCommand PROTOCOL_CODES.COPTER_EMERGENCY, null, cb
    this

  disconnect: (cb = (->)) ->
    return if not super
    @sendCommand PROTOCOL_CODES.COPTER_DISCONNECT, null, ->
      @copterid = null
      cb()
    this
