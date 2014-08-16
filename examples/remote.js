var coptermanager = require('coptermanager');
var client = coptermanager.createRemoteClient({endpoint: 'http://localhost:4000/api'});

client.bind();

client
  .after(5000, function() {
    this.takeoff();
  })
  .after(1000, function() {
    this.ledOn();
  })
  .after(3000, function() {
    this.flipOn();
  })
  .after(1000, function() {
    this.land();
  })
  .after(1000, function() {
    this.disconnect();
  });
