EventEmitter = require('events').EventEmitter
_ = require 'underscore'
Environment = require './utils/environment'
Client = require './client'
Drivers = require './drivers'

class ClientFactory

  _.extend @prototype, EventEmitter.prototype

  createSerialPortClient: (options = {}) ->
    client = new Clients.SerialPortClient(options)
    @emit 'create', client
    return client

  createLocalClient: ClientFactory::createSerialPortClient

  createWebClient: (options = {}) ->
    options.driver = Drivers.WebDriver
    client = new Client(options)
    @emit 'create', client
    return client

  createRemoteClient: ClientFactory::createWebClient

module.exports = clientFactory = new ClientFactory

if Environment.isNode
  clientFactory.on 'create', (client) ->
    client.on 'log', console.log
