path = require 'path'

IpythonView = require './ipython-view'
IPythonKernelManager = require './ipython-kernel-manager'
{route_output, route_input} = require './router'
iopub_handlers = require './iopub-handlers'
shell_handlers = require './shell-handlers'
input_handlers = require './input-handlers'

ipURI = 'atom://ipython'

createIPythonView = ->

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

displayError = (text) ->
  console.log(text)



module.exports =
  ipythonView: null

  configDefaults:
    existingKernelFile: ''
    ipythonDirectory: path.join process.env.HOME, ".ipython"
    ipythonProfile: 'default'
    ipythonExecutable: ''

  activate: (state) ->

    atom.project.registerOpener (filePath) =>
      createIPythonView() if filePath == ipURI

    atom.workspaceView.command "ipython:start", ->
      atom.workspaceView.open(ipURI)

  deactivate: ->
    @ipythonView.destroy()
    @ipythonKernelManager.destroy()

  serialize: ->
    ipythonViewState: @ipythonView.serialize()
