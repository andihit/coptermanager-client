var coptermanager = exports;

exports.Client = require('./client');
exports.Drivers = require('./drivers');

exports.createDebugClient = function(options) {
  options = options || {};
  options.driver = new coptermanager.Drivers.Debug(options);

  var client = new coptermanager.Client(options);
  return client;
};

exports.createSerialPortClient = function(options) {
  options = options || {};
  options.driver = new coptermanager.Drivers.SerialPort(options);

  var client = new coptermanager.Client(options);
  return client;
};
exports.createLocalClient = coptermanager.createSerialPortClient;

exports.createWebClient = function(options) {
  options = options || {};
  options.driver = new coptermanager.Drivers.Web(options);

  var client = new coptermanager.Client(options);
  return client;
};
