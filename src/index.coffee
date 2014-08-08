coptermanager = module.exports
module.exports.Clients = require './clients'


module.exports.createSerialPortClient = (options = {}) ->
  client = new coptermanager.Clients.SerialPortClient(options)
  return client

module.exports.createLocalClient = coptermanager.createSerialPortClient


module.exports.createWebClient = (options = {}) ->
  client = new coptermanager.Clients.WebClient(options)
  return client

module.exports.createRemoteClient = coptermanager.createWebClient
