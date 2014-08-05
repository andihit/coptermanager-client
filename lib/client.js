var util = require('util');

function Client(options) {
  options = options || {};

  this.driver = options.driver;
  this._afterOffset = 0;
}

Client.prototype.after = function(duration, fn) {
  setTimeout(fn.bind(this), this._afterOffset + duration);
  this._afterOffset += duration;
  return this;
};

Client.prototype.is_connected = function() {
  return this.driver.is_connected();
};

Client.prototype.takeoff = function(cb, type) {
  if (this.is_connected()) {
    util.error("this drone is already connected");
    return;
  }

  this.driver.takeoff(cb, type);
  return this;
};

Client.prototype.clockwise = function(degree, cb) {
  if (!this.is_connected()) {
    util.error("this drone is not connected");
    return;
  }

  this.driver.rotate(degree, cb);
  return this;
};

Client.prototype.flip = function(cb) {
  if (!this.is_connected()) {
    util.error("this drone is not connected");
    return;
  }

  this.driver.flip(cb);
  return this;
};

Client.prototype.ledOn = function(cb) {
  if (!this.is_connected()) {
    util.error("this drone is not connected");
    return;
  }

  this.driver.led('on', cb);
  return this;
};

Client.prototype.ledOff = function(cb) {
  if (!this.is_connected()) {
    util.error("this drone is not connected");
    return;
  }

  this.driver.led('off', cb);
  return this;
};

Client.prototype.land = function(cb) {
  if (!this.is_connected()) {
    util.error("this drone is not connected");
    return;
  }

  this.driver.land(cb);
  return this;
};

module.exports = Client;
