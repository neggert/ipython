IpythonView = require './ipython-view'
IPythonKernelManager = require './ipython-kernel-manager'

ipURI = 'atom://ipython'

createIPythonView = (state) ->
  handle_input = (cmd, id) =>
    console.log "input id "+id
    ipKernelManager.execute_command cmd, id
    ipView.new_io()

  handle_exec_reply = (id, n) =>
    console.log "reply id " + id
    ipView.io_views[id].set_n n

  handle_output = (x, id, n) =>
    console.log "output "+id+" "+x
    ipView.io_views[id].output(x, n)

  ipKernelManager = new IPythonKernelManager()
  ipView = new IpythonView handle_input

  ipKernelManager.on_output handle_output
  ipKernelManager.on_reply handle_exec_reply

  ipView

module.exports =
  ipythonView: null

  activate: (state) ->
    atom.project.registerOpener (filePath) ->
      createIPythonView(filePath) if filePath == ipURI

    atom.workspaceView.command "ipython:start", ->
      atom.workspaceView.open(ipURI)


  deactivate: ->
    @ipythonView.destroy()

  serialize: ->
    ipythonViewState: @ipythonView.serialize()
