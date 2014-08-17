coptermanager = require('coptermanager')
client = coptermanager.createRemoteClient(endpoint: 'http://localhost:4000/api')

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
