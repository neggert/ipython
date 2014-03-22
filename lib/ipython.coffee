IpythonView = require './ipython-view'
IPythonKernelManager = require './ipython-kernel-manager'

module.exports =
  ipythonView: null

  activate: (state) ->
    input = (cmd, id) =>
      console.log "input id "+id
      @ipythonKernelManager.execute_command cmd, id

    output = (x, id, n) =>
      console.log "output "+id+" "+x
      @ipythonView.io_views[id].output(x, n)

    @ipythonKernelManager = new IPythonKernelManager()
    @ipythonKernelManager.on_output output

    @ipythonView = new IpythonView input

  deactivate: ->
    @ipythonView.destroy()

  serialize: ->
    ipythonViewState: @ipythonView.serialize()
