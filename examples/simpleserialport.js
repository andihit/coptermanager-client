var coptermanager = require('coptermanager');
var client = coptermanager.createSimpleSerialPortClient({serialport: '/dev/tty.usbmodem1411'});

client.bind(function() {

  client.takeoff()
  .after(2000, function() {
    this.throttle(-5);
    this.throttle(20);
  })
  .after(1000, function() {
    this.ledOff();
  })
  .after(1000, function() {
    this.land();
  })
  .after(1000, function() {
    this.disconnect();
  });

});
