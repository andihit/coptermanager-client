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
    @driver.on 'init', (data) => @emit 'init', data
    @driver.on 'bind', (data) => @emit 'bind', data
    @driver.on 'disconnect', => @emit 'disconnect'

    @afterOffset = 0
    @timeouts = []

  # utility functions

  after: (duration, fn) ->
    @timeouts.push setTimeout(fn.bind(this), @afterOffset + duration)
    @afterOffset += duration
    return this

  bindCallback: (cb) ->
    if cb
      return cb.bind(this)
    else
      return cb

  exit: ->
    @log.info('exiting...')
    clearTimeout timeout for timeout in @timeouts

  isConnected: ->
    return @driver.isConnected()

  requireConnected: ->
    if @isConnected()
      return true
    else
      @log.error('this drone is not connected')
      return false

  isBound: ->
    return @driver.isBound()

  requireBound: ->
    if @isBound()
      return true
    else
      @log.error('this drone is not bound')
      @exit()
      return false

  # api methods

  bind: (cb = (->)) ->
    if @isConnected() and not @isBound()
      @log.error('this drone is already connected but not bound. try powering the drone off and on again...')
      @exit()
      return false
      
    if @isBound()
      @log.error('this drone is already bound')
      @exit()
      return false

    @log.info('bind')
    @driver.bind(@bindCallback(cb))
    return this

  throttle: (value, cb = (->)) ->
    return if not @requireBound()

    @log.info("throttle #{value}")
    @driver.throttle(value, @bindCallback(cb))
    return this

  rudder: (value, cb = (->)) ->
    return if not @requireBound()
    
    @log.info("rudder #{value}")
    @driver.rudder(value, @bindCallback(cb))
    return this

  aileron: (value, cb = (->)) ->
    return if not @requireBound()
    
    @log.info("aileron #{value}")
    @driver.aileron(value, @bindCallback(cb))
    return this

  elevator: (value, cb = (->)) ->
    return if not @requireBound()
    
    @log.info("elevator #{value}")
    @driver.elevator(value, @bindCallback(cb))
    return this

  setFlip: (state, cb = (->)) ->
    return if not @requireBound()
      
    @log.info("set flip #{state}")
    @driver.setFlip(state, @bindCallback(cb))
    return this

  flipOn: (cb) -> @setFlip('on', cb)
  flipOff: (cb) -> @setFlip('off', cb)

  setLed: (state, cb = (->)) ->
    return if not @requireBound()
    
    @log.info("set led #{state}")
    @driver.setLed(state, @bindCallback(cb))
    return this

  ledOn: (cb) -> @setLed('on', cb)
  ledOff: (cb) -> @setLed('off', cb)

  setVideo: (state, cb = (->)) ->
    return if not @requireBound()
      
    @log.info("set video #{state}")
    @driver.setVideo(state, @bindCallback(cb))
    return this

  videoOn: (cb) -> @setVideo('on', cb)
  videoOff: (cb) -> @setVideo('off', cb)

  telemetry: (option, cb = (->)) ->
    return if not @requireBound()
      
    @log.info('telemetry')
    @driver.telemetry(option, @bindCallback(cb))
    return this

  emergency: (cb = (->)) ->
    return if not @requireBound()
      
    @log.info('emergency')
    @driver.emergency(@bindCallback(cb))
    return this

  disconnect: (cb = (->)) ->
    return if not @requireConnected()
      
    @log.info('disconnect')
    @driver.disconnect(@bindCallback(cb))
    return this

  # compound API methods

  takeoff: (cb = (->)) ->
    return if not @requireBound()

    @log.info('takeoff')

    # TODO optimize...
    @after 0, ->
      @driver.throttle(15)
    #@after 200, ->
    #  @driver.throttle(50)
    #@after 200, ->
    #  @driver.throttle(80)
    #@after 200, ->
    #  @driver.throttle(120)
    # after ... call cb with this
    return this

  land: (cb = (->)) ->
    return if not @requireBound()
      
    @log.info('land')
    # TODO: smooth land
    return this
