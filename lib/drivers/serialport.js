var SerialPort = require("serialport").SerialPort

var PROTOCOL_CODES = {
  COPTER_BIND:      0x01,
  COPTER_THROTTLE:  0x02,
  COPTER_RUDDER:    0x03,
  COPTER_AILERON:   0x04,
  COPTER_ELEVATOR:  0x05,
  COPTER_LED:       0x06,
  COPTER_FLIP:      0x07,
  COPTER_VIDEO:     0x08,
  COPTER_LAND:      0x09,
};

var COPTER_TYPES = {
  HUBSAN_X4: 0x01
};

function SerialPortDriver(options) {
  options = options || {};
  options.port = options.port || "/dev/tty-usbserial1";

  this._copterid = -1;
  this._serialPort = new SerialPort(options.port, {
    baudrate: 115200
  });
}

SerialPortDriver.prototype._send = function(copterid, command, value, cb) {
  var to_send = new Buffer(3);
  to_send.writeUInt8(copterid, 0);
  to_send.writeUInt8(command, 1);
  to_send.writeUInt8(value, 2);

  this._serialPort.write(to_send, function(err, results) {
    console.log('err ' + err);
    console.log('results ' + results);

    this._serialPort.once("data", function (data) {
      console.log("got data: "+data);
      if (data < 0)
        console.log("error");
      else
        cb && cb(data);
    });
  });
};

SerialPortDriver.prototype.is_connected = function() {
  return this._copterid > 0;
};

SerialPortDriver.prototype.takeoff = function(cb, type) {
  type = type || COPTER_TYPES.HUBSAN_X4;

  this._send(0, PROTOCOL_CODES.COPTER_BIND, type, function(copterid) {
    if (copterid > 0) {
      this._copterid = copterid;
      cb && cb();
    }
  });
};

SerialPortDriver.prototype.rotate = function(degrees, cb) {
  console.log("rotate", degrees);
  cb && cb();
};

SerialPortDriver.prototype.flip = function(cb) {
  this._send(this._copterid, PROTOCOL_CODES.COPTER_FLIP, 0x01, cb);
};

SerialPortDriver.prototype.led = function(state, cb) {
  this._send(this._copterid, PROTOCOL_CODES.COPTER_LED, state === 'on' ? 0x01 : 0x00, cb);
};

SerialPortDriver.prototype.land = function(cb) {
  this._send(this._copterid, PROTOCOL_CODES.COPTER_LAND, 0x00, cb);
};

module.exports = SerialPortDriver;
