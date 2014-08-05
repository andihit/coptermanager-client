var coptermanager = require('coptermanager');
var client = coptermanager.createWebClient({endpoint: 'http://localhost:4000/api'});

client.takeoff();

client
  .after(5000, function() {
    this.clockwise(0.5);
  })
  .after(1000, function() {
    this.ledOn();
  })
  .after(3000, function() {
    this.flip();
  })
  .after(1000, function() {
    this.land();
  });
