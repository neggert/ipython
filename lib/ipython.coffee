IpythonView = require './ipython-view'
IPythonKernelManager = require './ipython-kernel-manager'
{route_output, route_input} = require './router'
iopub_handlers = require './iopub-handlers'
shell_handlers = require './shell-handlers'
input_handlers = require './input-handlers'

ipURI = 'atom://ipython'

createIPythonView = (state) ->

  route_cmd_input = (input_type, msg_id, text) ->
    route_input input_handlers, ipKernelManager, ipView, input_type, msg_id, text

  route_shell = (msg...) ->
    route_output shell_handlers, ipKernelManager, ipView, msg

  route_iopub = (msg...) ->
    route_output iopub_handlers, ipKernelManager, ipView, msg

  ipKernelManager = new IPythonKernelManager()
  ipView = new IpythonView route_cmd_input

  ipKernelManager.on_iopub route_iopub
  ipKernelManager.on_shell route_shell

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
