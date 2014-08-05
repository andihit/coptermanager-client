Coptermanager
=============

A node.js library for controlling your (mini) drones (like the popular Hubsan X4). Heavily inspired by nodecopter.com / felixge/node-ar-drone.


Example
-------

```js
var coptermanager = require('coptermanager');
var client = coptermanager.createLocalClient();

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
```
