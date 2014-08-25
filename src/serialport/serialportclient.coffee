SerialPort = require('serialport').SerialPort
_ = require 'underscore'
TELEMETRY_DATA = require('../serialport/protocol').TELEMETRY_DATA
PROTOCOL_CODES = require('../serialport/protocol').PROTOCOL_CODES
RESULT_CODES = require('../serialport/protocol').RESULT_CODES

module.exports = class SerialPortClient

  constructor: ->
    @readBuffer = new Buffer([])
    @readFifo = []

  getErrorMessage: (resultCode) ->
    switch resultCode
      when RESULT_CODES.PROTOCOL_INVALID_COPTER_TYPE then 'invalid copter type'
      when RESULT_CODES.PROTOCOL_ALL_SLOTS_FULL then 'all slots are full'
      when RESULT_CODES.PROTOCOL_INVALID_SLOT then 'invalid slot'
      when RESULT_CODES.PROTOCOL_VALUE_OUT_OF_RANGE then 'value out of range'
      when RESULT_CODES.PROTOCOL_EMERGENCY_MODE_ON then 'emergency mode on'
      when RESULT_CODES.PROTOCOL_NO_TELEMETRY then 'no telemetry available. telemetry works only if max. 1 copter is bound'
      when RESULT_CODES.PROTOCOL_INVALID_TELEMETRY_OPTION then 'invalid telemetry option'
      when RESULT_CODES.PROTOCOL_UNKNOWN_COMMAND then 'unknown command'
      else 'unknown error'

  calculateChecksum: (data) ->
    sum = 0
    for d in data
      sum += d
    return (256 - (sum % 256)) & 0xFF

  processPacket: (packet, cb) ->
    checksum = packet[packet.length-1]
    if checksum != @calculateChecksum(packet.slice(0, packet.length-1))
      cb(result: 'error', error: 'received invalid checksum')
    else
      resultCode = packet[0]
      if resultCode != RESULT_CODES.PROTOCOL_OK
        cb(result: 'error', resultCode: resultCode, error: @getErrorMessage(resultCode))
      else
        cb({result: 'success'}, packet.slice(1, packet.length-1))

  dataReceived: (data) =>
    @readBuffer = Buffer.concat([@readBuffer, data])
    while @readFifo.length > 0
      # first element of read fifo
      responseLength = @readFifo[0][0]
      cb = @readFifo[0][1]

      if @readBuffer.length >= responseLength + 2 # responseLength + responseCode + checksum
        @readFifo.shift() # remove first element
        packet = @readBuffer.slice(0, responseLength + 2)
        @readBuffer = @readBuffer.slice(responseLength + 2)
        @processPacket(packet, cb)
      else
        # first element of read fifo doesn't match, break loop (wait until more data is in buffer)
        break

  open: (serialport, baudrate = 115200, cb = (->)) ->
    @serialPort = new SerialPort serialport, {baudrate: baudrate}, true, (error) =>
      if error
        cb(result: 'error', error: "Serial port error: #{error}")
      else
        @serialPort.on 'data', @dataReceived
        cb(result: 'success')

  sendRawCommand: (copterid, commandcode, value, responseLength, cb) ->
    checksum = (256 - ((copterid + commandcode + value) % 256)) & 0xFF
    buffer = new Buffer([copterid, commandcode, value, checksum])

    @readFifo.push [responseLength, cb]
    @serialPort.write buffer, (error, results) =>
      if error
        cb(result: 'error', error: "Serial port error: #{error}")

  telemetrySettings: (telemetry_data, cb) ->
    switch telemetry_data
      when 'altitude'
        valuecode: TELEMETRY_DATA.TELEMETRY_ALTITUDE
        responseLength: 2
        fn: (data, response) ->
          if data.result == 'success'
            data.altitude = response[0] << 8 | response[1]
          cb(data)
      when 'voltage'
        valuecode: TELEMETRY_DATA.TELEMETRY_VOLTAGE
        responseLength: 1
        fn: (data, response) ->
          if data.result == 'success'
            data.voltage = response[0]
          cb(data)
      when 'gyroscope'
        valuecode: TELEMETRY_DATA.TELEMETRY_GYROSCOPE
        responseLength: 6
        fn: (data, response) ->
          if data.result == 'success'
            data.gyroscope =
              x: response[0] << 8 | response[1]
              y: response[2] << 8 | response[3]
              z: response[4] << 8 | response[5]
          cb(data)
      when 'accelerometer'
        valuecode: TELEMETRY_DATA.TELEMETRY_ACCELEROMETER
        responseLength: 6
        fn: (data, response) ->
          if data.result == 'success'
            data.accelerometer =
              x: response[0] << 8 | response[1]
              y: response[2] << 8 | response[3]
              z: response[4] << 8 | response[5]
          cb(data)
      when 'angle'
        valuecode: TELEMETRY_DATA.TELEMETRY_ANGLE
        responseLength: 6
        fn: (data, response) ->
          if data.result == 'success'
            data.angle =
              roll:  response[0] << 8 | response[1]
              pitch: response[2] << 8 | response[3]
              yaw:   response[4] << 8 | response[5]
          cb(data)

  sendCommand: (copterid, command, value, cb = (->)) ->
    switch command
      when 'bind'
        @sendRawCommand 0, PROTOCOL_CODES.COPTER_BIND, value, 1, (data, response) ->
          if data.result == 'success'
            data.copterid = response[0]
          cb(data)

      when 'throttle' then @sendRawCommand copterid, PROTOCOL_CODES.COPTER_THROTTLE, value, 0, cb
      when 'rudder' then @sendRawCommand copterid, PROTOCOL_CODES.COPTER_RUDDER, value, 0, cb
      when 'aileron' then @sendRawCommand copterid, PROTOCOL_CODES.COPTER_AILERON, value, 0, cb
      when 'elevator' then @sendRawCommand copterid, PROTOCOL_CODES.COPTER_ELEVATOR, value, 0, cb

      when 'flip' then @sendRawCommand copterid, PROTOCOL_CODES.COPTER_FLIP, (if value == 'on' then 1 else 0), 0, cb
      when 'led' then @sendRawCommand copterid, PROTOCOL_CODES.COPTER_LED, (if value == 'on' then 1 else 0), 0, cb
      when 'video' then @sendRawCommand copterid, PROTOCOL_CODES.COPTER_VIDEO, (if value == 'on' then 1 else 0), 0, cb

      when 'getstate'
        @sendRawCommand copterid, PROTOCOL_CODES.COPTER_GETSTATE, 0, 1, (data, response) ->
          if data.result == 'success'
            data.state = if response[0] == 1 then 'bound' else 'unbound'
          cb(data)

      when 'telemetry'
        settings = @telemetrySettings(value, cb)
        @sendRawCommand copterid, PROTOCOL_CODES.COPTER_TELEMETRY, settings.valuecode, settings.responseLength, settings.fn

      when 'emergency' then @sendRawCommand copterid, PROTOCOL_CODES.COPTER_EMERGENCY, 0, 0, cb
      when 'disconnect' then @sendRawCommand copterid, PROTOCOL_CODES.COPTER_DISCONNECT, 0, 0, cb

      when 'listcopters'
        @sendRawCommand 0, PROTOCOL_CODES.COPTER_LISTCOPTERS, 0, 1, (data, response) ->
          if data.result == 'success'
            data.copters = []
            # bitmask is 1 byte - 8 bits = 8 possible slots
            bitmask = response[0]
            for copterid in [1..8]
              if bitmask & (1 << (copterid-1))
                data.copters.push copterid
          cb(data)

  close: (cb = (->)) ->
    @serialPort.close(cb)
