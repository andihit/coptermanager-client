# Coptermanager

A set of applications to program your quadrocopters. Contains code for the transmitter station (arduino board with A7105 chip), a server application to control your drones in the browser and execute custom code using a JavaScript API, and a node.js package for connecting to a local or remote transmitter station.

## Overview

  * [coptermanager-arduino](https://github.com/andihit/coptermanager-arduino): arduino application which communicates with the quadrocopters
  * [coptermanager_server](https://github.com/andihit/coptermanager_server): web interface and HTTP API for controlling multiple quadrocopters
  * [coptermanager-client](https://github.com/andihit/coptermanager-client): client library to control quadrocopters with javascript (node.js)

## Possible setups

### Variant 1: full stack solution

This setup is recommended. It allows you to control multiple quadrocopters with just a single arduino board and transmitter chip. You can open the webinterface and start programming right away, inside the browser. Furthermore you can connect other apps to the HTTP API (e.g. apps for mobile devices).

### Variant 2: coptermanager-arduino and coptermanager-client

It is also possible to talk directly from the client to the arduino board. The JavaScript API is identical to variant 1.

## Requirements

  * [coptermanager-arduino](https://github.com/andihit/coptermanager-arduino) or [coptermanager_server](https://github.com/andihit/coptermanager_server)
  * [node.js](http://nodejs.org) if you don't use [coptermanager_server](https://github.com/andihit/coptermanager_server)

## Setup instructions with [coptermanager_server](https://github.com/andihit/coptermanager_server) (variant 1)

**Not setup required :) You can execute the code direct in the webinterface.**

## Setup instructions without [coptermanager_server](https://github.com/andihit/coptermanager_server) (variant 2)

1. Clone this repository.
2. Navigate to this folder and execute `npm install`, `npm link`.
3. Test some examples in the `examples/` directory (`node local.js`).


## Documentation

### Code example

```js
var coptermanager = require('coptermanager');
var client = coptermanager.createLocalClient({serialport: '/dev/tty.usbmodem1411', baudrate: 115200});

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
```
