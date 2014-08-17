var coptermanager = require('coptermanager');
var client = coptermanager.createLocalClient({serialport: '/dev/tty.usbmodem1411'});

client.bind(function() {

  client.takeoff()
  .after(5000, function() {
    this.elevator(112);
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
