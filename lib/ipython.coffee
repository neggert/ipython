IpythonView = require './ipython-view'
IPythonKernelManager = require './ipython-kernel-manager'
route = require './router'
iopub_handlers = require './iopub-handlers'

ipURI = 'atom://ipython'

createIPythonView = (state) ->
  handle_input = (cmd, id) =>
    console.log "input id "+id
    ipKernelManager.execute_command cmd, id
    ipView.new_io()

  handle_exec_reply = (id, n) =>
    console.log "reply id " + id
    ipView.ioViews[id].set_n n

  route_iopub = (msg...) ->
    console.log "iopub message"
    route iopub_handlers, ipKernelManager, ipView, msg

  ipKernelManager = new IPythonKernelManager()
  ipView = new IpythonView handle_input

  ipKernelManager.on_iopub route_iopub
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
