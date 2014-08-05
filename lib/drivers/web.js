var util = require('util');
var rest = require('restler');

function WebDriver(options) {
  options = options || {};
  
  this._endpoint = options.endpoint;
  this._copterid = 0;
}

WebDriver.prototype._sendCommand = function(command, value, cb) {
  rest.post(this._endpoint + '/copter/' + this._copterid + '/' + command, {
    data: {
      value: value
    },
  }).on('complete', function(data, response) {
    cb && cb(data.code);
  });
};

WebDriver.prototype.is_connected = function() {
  return this._copterid > 0;
};

WebDriver.prototype.takeoff = function(cb, type) {
  type = type || 'hubsan_x4';

  var that = this;
  util.log('Sending takeoff... ');
  rest.post(this._endpoint + '/copter/', {
    data: {
      type: type
    },
  }).on('complete', function(data, response) {
    that._copterid = data.copterid;
    cb && cb(data.copterid);
  });
};

WebDriver.prototype.rotate = function(degrees, cb) {
  console.log("TODO");
};

WebDriver.prototype.flip = function(cb) {
  util.log('Sending flip... ');
  this._sendCommand('flip', 1, cb);
};

WebDriver.prototype.led = function(state, cb) {
  util.log('Sending led ' + state + '... ');
  this._sendCommand('led', state, cb);
};

WebDriver.prototype.land = function(cb) {
  util.log('Sending land... ');
  this._sendCommand('land', 0, cb);
};

module.exports = WebDriver;
