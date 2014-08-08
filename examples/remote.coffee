coptermanager = require('coptermanager')
client = coptermanager.createRemoteClient(endpoint: 'http://localhost:4000/api')

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
.after 0, ->
  this.disconnect()
