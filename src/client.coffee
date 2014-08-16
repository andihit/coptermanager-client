EventEmitter = require('events').EventEmitter
moment = require 'moment'
_ = require 'underscore'
Log = require './utils/log'

module.exports = class Client

  _.extend @prototype, EventEmitter.prototype

  constructor: (options = {}) ->
    if not options.driver
      throw 'please specify a driver'

    loglevel = options.loglevel or Log.Loglevel.INFO
    logOutputFn = (msg) => @emit 'log', msg
    @log = new Log.Logger(loglevel, moment(), logOutputFn)

    options.log = @log
    @driver = new options.driver(options)
    @driver.on 'log', (msg) => @emit 'log', msg
    @driver.on 'exit', => @exit()
    @driver.on 'bind', (data) => @emit 'bind', data
    @driver.on 'disconnect', => @emit 'disconnect'

    @afterOffset = 0
    @timeouts = []

  # utility functions

  after: (duration, fn) ->
    @timeouts.push setTimeout(fn.bind(this), @afterOffset + duration)
    @afterOffset += duration
    return this

  exit: ->
    @log.info('exiting...')
    clearTimeout timeout for timeout in @timeouts

  isConnected: ->
    return @driver.isConnected()

  requireConnection: ->
    if @isConnected()
      return true
    else
      @log.error('this drone is not connected')
      @exit()
      return false

  # api methods

  bind: (type = 'hubsan_x4', options = {}, cb = (->)) ->
    if @isConnected()
      @log.error('this drone is already connected')
      @exit()
      return false

    @log.info('bind')
    @driver.bind(type, options, cb)
    return this

  throttle: (value, cb = (->)) ->
    return if not @requireConnection()

    @log.info("throttle #{value}")
    @driver.throttle(value, cb)
    return this

  rudder: (value, cb = (->)) ->
    return if not @requireConnection()
    
    @log.info("rudder #{value}")
    @driver.rudder(value, cb)
    return this

  aileron: (value, cb = (->)) ->
    return if not @requireConnection()
    
    @log.info("aileron #{value}")
    @driver.aileron(value, cb)
    return this

  elevator: (value, cb = (->)) ->
    return if not @requireConnection()
    
    @log.info("elevator #{value}")
    @driver.elevator(value, cb)
    return this

  setFlip: (state, cb = (->)) ->
    return if not @requireConnection()
      
    @log.info("set flip #{state}")
    @driver.setFlip(state, cb)
    return this

  flipOn: (cb) -> @setFlip('on', cb)
  flipOff: (cb) -> @setFlip('off', cb)

  setLed: (state, cb = (->)) ->
    return if not @requireConnection()
    
    @log.info("set led #{state}")
    @driver.setLed(state, cb)
    return this

  ledOn: (cb) -> @setLed('on', cb)
  ledOff: (cb) -> @setLed('off', cb)

  setVideo: (state, cb = (->)) ->
    return if not @requireConnection()
      
    @log.info("set video #{state}")
    @driver.setVideo(state, cb)
    return this

  videoOn: (cb) -> @setVideo('on', cb)
  videoOff: (cb) -> @setVideo('off', cb)

  emergency: (cb = (->)) ->
    return if not @requireConnection()
      
    @log.info('emergency')
    @driver.emergency(cb)
    return this

  disconnect: (cb = (->)) ->
    return if not @requireConnection()
      
    @log.info('disconnect')
    @driver.disconnect(cb)
    return this

  # compound API methods

  takeoff: (cb = (->)) ->
    return if not @requireConnection()

    @log.info('takeoff')
    # TODO set THROTTLE
    return this

  land: (cb = (->)) ->
    return if not @requireConnection()
      
    @log.info('land')
    # TODO: smooth land
    return this
