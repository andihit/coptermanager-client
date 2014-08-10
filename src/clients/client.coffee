EventEmitter = require('events').EventEmitter
moment = require 'moment'
_ = require 'underscore'
Log = require '../utils/log'

module.exports = class Client

  _.extend @prototype, EventEmitter.prototype
  _.extend @prototype, Log.Logger

  constructor: (options = {}) ->
    options.loglevel = Log.Loglevel.INFO

    @name = null
    @copterid = null
    @startTime = moment()

    @afterOffset = 0
    @timeouts = []
    @loglevel = options.loglevel

  after: (duration, fn) ->
    @timeouts.push setTimeout(fn.bind(this), @afterOffset + duration)
    @afterOffset += duration
    return this

  exit: ->
    clearTimeout timeout for timeout in @timeouts

  is_connected: ->
    return !!@copterid

  takeoff: (name, type, cb = (->)) ->
    if @is_connected()
      @error('this drone is already connected')
      @exit()
      return false

    if name
      @name = name
    else
      @name = 'copter' + Math.round(Math.random() * 1000)

    @info('takeoff ' + @name)
    return this

  clockwise: (degrees, cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      @exit()
      return false
      
    @info('rotate clockwise ' + degrees + '°')
    return this

  setFlip: (state, cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      @exit()
      return false
      
    @info('set flip ' + state)
    return this

  flipOn: (cb) -> @setFlip('on', cb)
  flipOff: (cb) -> @setFlip('off', cb)

  setLed: (state, cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      @exit()
      return false
      
    @info('set led ' + state)
    return this

  ledOn: (cb) -> @setLed('on', cb)
  ledOff: (cb) -> @setLed('off', cb)

  land: (cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      @exit()
      return false
      
    @info('land')
    return this

  emergency: (cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      @exit()
      return false
      
    @info('emergency')
    return this

  disconnect: (cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      @exit()
      return false
      
    @info('disconnect')
    return this
