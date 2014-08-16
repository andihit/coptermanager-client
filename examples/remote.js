var coptermanager = require('coptermanager');
var client = coptermanager.createRemoteClient({endpoint: 'http://localhost:4000/api'});

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
