fs = require 'fs'
path = require 'path'

IpythonView = require './ipython-view'
IPythonKernelManager = require './ipython-kernel-manager'
{route_output, route_input} = require './router'
iopub_handlers = require './iopub-handlers'
shell_handlers = require './shell-handlers'
input_handlers = require './input-handlers'

ipURI = 'atom://ipython'

createIPythonView = (settings) ->

  route_cmd_input = (input_type, msg_id, text) ->
    route_input input_handlers, ipKernelManager, ipView, input_type, msg_id, text

  route_shell = (msg...) ->
    route_output shell_handlers, ipKernelManager, ipView, msg

  route_iopub = (msg...) ->
    route_output iopub_handlers, ipKernelManager, ipView, msg

  ipKernelManager = new IPythonKernelManager settings
  ipView = new IpythonView route_cmd_input

  ipKernelManager.on_iopub route_iopub
  ipKernelManager.on_shell route_shell

  ipView

displayError = (text) ->
  console.log(text)

getIPythonSettings = ->
  ipDir = atom.config.get "ipython.ipythonDirectory"
  ipProfileDir = "profile_" + atom.config.get "ipython.ipythonProfile"
  profileDir = path.join ipDir, ipProfileDir
  kernelFileName = path.join profileDir, "security", atom.config.get "ipython.existingKernelFile"

  try
    settingsFile = fs.readFileSync kernelFileName
  catch err
    displayError err.message
    throw err

  JSON.parse settingsFile

module.exports =
  ipythonView: null

  configDefaults:
    existingKernelFile: ''
    ipythonDirectory: path.join process.env.HOME, ".ipython"
    ipythonProfile: 'default'

  activate: (state) ->
    try
      settings = getIPythonSettings()
    catch err
      return

    atom.project.registerOpener (filePath) =>
      createIPythonView(settings) if filePath == ipURI

    atom.workspaceView.command "ipython:start", ->
      atom.workspaceView.open(ipURI)


  deactivate: ->
    @ipythonView.destroy()

  serialize: ->
    ipythonViewState: @ipythonView.serialize()
