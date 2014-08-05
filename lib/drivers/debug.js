var moment = require('moment');


function Debug(options) {
  options = options || {};
  this._copterid = -1;
  this._startTime = moment();
}

Debug.prototype.print = function() {
  var timeElapsed = moment().diff(this._startTime);
  var durationStr = moment.utc(timeElapsed).format("mm:ss.SSS");

  var args = Array.prototype.slice.call(arguments, 0);
  args.unshift('[' + durationStr + ']');
  console.log.apply(this, args);
}

Debug.prototype.is_connected = function() {
  return this._copterid > 0;
};

Debug.prototype.takeoff = function(cb) {
  this.print("takeoff");
  this._copterid = 1;
  cb && cb();
};

Debug.prototype.rotate = function(degrees, cb) {
  this.print("rotate", degrees + "°");
  cb && cb();
};

Debug.prototype.flip = function(cb) {
  this.print("flip");
  cb && cb();
};

Debug.prototype.led = function(state, cb) {
  this.print("led", state);
  cb && cb();
};

Debug.prototype.land = function(cb) {
  this.print("land");
  cb && cb();
};

module.exports = Debug;
