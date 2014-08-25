EventEmitter = require('events').EventEmitter
_ = require 'underscore'
Environment = require './utils/environment'
Client = require './client'
Drivers = require './drivers'

class ClientFactory

  _.extend @prototype, EventEmitter.prototype

  createClient: (options) ->
    client = new Client(options)
    @emit 'create', client
    return client

  createSerialPortClient: (options = {}) ->
    options.driver = Drivers.SerialPortDriver
    return @createClient(options)

  createLocalClient: ClientFactory::createSerialPortClient

  createSimpleSerialPortClient: (options = {}) ->
    options.driver = Drivers.SimpleSerialPortDriver
    return @createClient(options)

  createWebClient: (options = {}) ->
    options.driver = Drivers.WebDriver
    return @createClient(options)

  createRemoteClient: ClientFactory::createWebClient

module.exports = clientFactory = new ClientFactory

if Environment.isNode
  clientFactory.on 'create', (client) ->
    client.on 'log', console.log
