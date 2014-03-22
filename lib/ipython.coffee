IpythonView = require './ipython-view'
IPythonKernelManager = require './ipython-kernel-manager'

module.exports =
  ipythonView: null

  activate: (state) ->
    input = (cmd, id) =>
      console.log "input id "+id
      @ipythonKernelManager.execute_command cmd, id

    handle_exec_reply = (id, n) =>
      console.log "reply id " + id
      @ipythonView.io_views[id].set_n n

    handle_output = (x, id, n) =>
      console.log "output "+id+" "+x
      @ipythonView.io_views[id].output(x, n)

    @ipythonKernelManager = new IPythonKernelManager()
    @ipythonKernelManager.on_output handle_output
    @ipythonKernelManager.on_reply handle_exec_reply

    @ipythonView = new IpythonView input

  deactivate: ->
    @ipythonView.destroy()

  serialize: ->
    ipythonViewState: @ipythonView.serialize()
