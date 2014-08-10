coptermanager = require('coptermanager')
client = coptermanager.createLocalClient(port: '/dev/ttyS0', baudrate: 9600)

client
.takeoff()
.after 5000, ->
  this.clockwise(50)
.after 1000, ->
  this.ledOn()
.after 3000, ->
  this.flipOn()
.after 1000, ->
  this.land()
.after 1000, ->
  this.disconnect()
