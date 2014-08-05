var SerialPort = require("serialport").SerialPort

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

SerialPortDriver.prototype.takeoff = function(cb) {
  this._send(0, 0x01, 0x01, function(copterid) {
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
  this._send(this._copterid, 0x07, 0x01, cb);
};

SerialPortDriver.prototype.led = function(state, cb) {
  this._send(this._copterid, 0x06, state === 'on' ? 0x01 : 0x00, cb);
};

SerialPortDriver.prototype.land = function(cb) {
  this._send(this._copterid, 0x09, 0x00, cb);
};

module.exports = SerialPortDriver;
