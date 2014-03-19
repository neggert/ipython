
module.exports =
  class IPythonKernelManager
    constructor: ->
      @n = 0

    execute_command: (command) ->
      console.log "execute_command "+command
      setTimeout ( => @output_callback("output",@n)), 1000
      @n += 1

    on_output: (@output_callback) ->
