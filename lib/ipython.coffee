IpythonView = require './ipython-view'
IPythonKernelManager = require './ipython-kernel-manager'

module.exports =
  ipythonView: null

  activate: (state) ->
    input = (cmd) =>
      @ipythonKernelManager.execute_command cmd

    output = (x, n) =>
      console.log "output "+n+" "+x
      @ipythonView.io_views[n].output(x, n)

    @ipythonKernelManager = new IPythonKernelManager()
    @ipythonKernelManager.on_output output

    @ipythonView = new IpythonView input

  deactivate: ->
    @ipythonView.destroy()

  serialize: ->
    ipythonViewState: @ipythonView.serialize()
