moment = require 'moment'

Loglevel = {
  ERROR: 0,
  INFO: 1,
  DEBUG: 2
}

Logger = 
  print: (message) ->
    timeElapsed = moment().diff(@startTime)
    durationStr = moment.utc(timeElapsed).format("mm:ss.SSS")
    @emit 'log', '[' + durationStr + '] ' + message

  printLevel: (level, level_name, message) ->
    if @loglevel >= level
      @print('[' + level_name + '] ' + message);

  error: (message) -> @printLevel(Loglevel.ERROR, 'ERROR', message)
  info: (message) -> @printLevel(Loglevel.INFO, 'INFO', message)
  debug: (message) -> @printLevel(Loglevel.DEBUG, 'DEBUG', message)

module.exports =
  Logger: Logger,
  Loglevel: Loglevel
