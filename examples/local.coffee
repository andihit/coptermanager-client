coptermanager = require('coptermanager')
client = coptermanager.createLocalClient(serialport: '/dev/tty.usbmodem1411')

client.bind ->
  
  client.takeoff()
  .after 5000, ->
    @elevator(112)
  .after 1000, ->
    @ledOff()
  .after 1000, ->
    @land()
  .after 1000, ->
    @disconnect()
