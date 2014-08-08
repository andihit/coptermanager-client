moment = require 'moment'
_ = require 'underscore'
Log = require '../utils/log'

module.exports = class Client

  _.extend @prototype, Log.Logger

  constructor: (options = {}) ->
    options.loglevel = Log.Loglevel.INFO

    @copterid = 0
    @startTime = moment()

    @afterOffset = 0
    @loglevel = options.loglevel

  after: (duration, fn) ->
    setTimeout(fn.bind(this), @afterOffset + duration)
    @afterOffset += duration
    return this

  is_connected: ->
    return @copterid > 0

  takeoff: (type, cb = (->)) ->
    if @is_connected()
      @error('this drone is already connected')
      return false

    @info('takeoff')
    return this

  clockwise: (degrees, cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      return false
      
    @info('rotate clockwise ' + degrees + '°')
    return this

  setFlip: (state, cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      return false
      
    @info('set flip ' + state)
    return this

  flipOn: (cb) -> @setFlip('on', cb)
  flipOff: (cb) -> @setFlip('off', cb)

  setLed: (state, cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      return false
      
    @info('set led ' + state)
    return this

  ledOn: (cb) -> @setLed('on', cb)
  ledOff: (cb) -> @setLed('off', cb)

  land: (cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      return false
      
    @info('land')
    return this

  emergency: (cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      return false
      
    @info('emergency')
    return this

  disconnect: (cb = (->)) ->
    if not @is_connected()
      @error('this drone is not connected')
      return false
      
    @info('disconnect')
    return this
