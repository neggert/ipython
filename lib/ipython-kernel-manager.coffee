zmq = require 'zmq'
uuid = require 'node-uuid'
fs = require 'fs'
path = require 'path'
child_process = require 'child_process'

getFullKernelPath = (kernelFileName) ->
  ipDir = atom.config.get "ipython.ipythonDirectory"
  ipProfileDir = "profile_" + atom.config.get "ipython.ipythonProfile"
  profileDir = path.join ipDir, ipProfileDir
  path.join profileDir, "security", kernelFileName

getIPythonSettings = (kernelFileName) ->
  settingsFile = null
  i = 0

  # it can take a few ms for ipython to create the file
  # should find a way to make this non-blocking
  until settingsFile? or i > 100
    try
      settingsFile = fs.readFileSync kernelFileName
    catch err
      if i > 100
        alert err.message
        throw err
  JSON.parse settingsFile

getIPythonExecutable = () ->
  exe = atom.config.get "ipython.ipythonExecutable"
  if exe.length == 0
    "ipython"
  else
    exe

module.exports =
  class IPythonKernelManager
    constructor:  ->
      @session_id = uuid.v4().toString()
      @kernelProcess = null
      settings = @initializeKernel()

      @conn       = "tcp://"+settings.ip+":"
      @shell_port = settings.shell_port
      @iopub_port = settings.iopub_port
      @hb_port    = settings.hb_port

      @shell_socket = zmq.socket 'dealer'
      @iopub_socket = zmq.socket 'sub'
      @hb_socket    = zmq.socket 'req'

      @connect()
      @configure_sockets()
      @setup_hb(5000, 500)

    initializeKernel: =>
      kernelFileName = atom.config.get "ipython.existingKernelFile"
      kernelFileName = @launchKernel() if kernelFileName.length == 0
      getIPythonSettings(kernelFileName)

    launchKernel: =>
      ipythonExe = getIPythonExecutable()
      @kernelProcess = child_process.spawn ipythonExe, [
          "kernel"
          "--profile="+(atom.config.get "ipython.ipythonProfile")
          "--ipython-dir="+(atom.config.get "ipython.ipythonDirectory")
          "--no-secure"
        ],
        {
          cwd: process.cwd()
          env: process.env
          stdio: 'inherit'
        }
      kernelName = "kernel-"+@kernelProcess.pid+".json"
      getFullKernelPath kernelName

    connect: =>
      @shell_socket.connect @conn+@shell_port
      @iopub_socket.connect @conn+@iopub_port
      @hb_socket.connect @conn+@hb_port

    destroy: =>
      @kernelProcess?.kill()

    configure_sockets: =>
      @shell_socket.setsockopt zmq.ZMQ_IDENTITY, Buffer(@session_id)
      @iopub_socket.setsockopt zmq.ZMQ_SUBSCRIBE, Buffer('')

    send_shell: (msg) =>
      @shell_socket.send msg

    setup_hb: (time_between_hbs, hb_wait_time) =>
      setInterval ( =>
        hb_message = Date.now()
        @hb_socket.send hb_message
        @hb_socket._events = {}
        timeout = setTimeout ( ->
          alert('hb timeout')
          ), hb_wait_time
        @hb_socket.on 'message', (msg) =>
          clearTimeout timeout if msg = hb_message
      ), time_between_hbs

    on_iopub: (cb) =>
      @iopub_socket.on 'message', cb

    on_shell: (cb) ->
      @shell_socket.on 'message', cb
