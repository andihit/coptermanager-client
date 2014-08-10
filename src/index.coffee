Environment = require './utils/environment'

module.exports.Clients = require './clients'
coptermanager = module.exports

registerClient = (client) ->
  if Environment.isNode
    client.on 'log', console.log

  if Environment.isBrowser and window.coptermanager
    window.coptermanager.registerClient(client)


module.exports.createSerialPortClient = (options = {}) ->
  client = new coptermanager.Clients.SerialPortClient(options)
  registerClient(client)
  return client

module.exports.createLocalClient = coptermanager.createSerialPortClient


module.exports.createWebClient = (options = {}) ->
  client = new coptermanager.Clients.WebClient(options)
  registerClient(client)
  return client

module.exports.createRemoteClient = coptermanager.createWebClient
