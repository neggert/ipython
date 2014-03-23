zmq = require 'zmq'
uuid = require 'node-uuid'

module.exports =
  class IPythonKernelManager
    constructor: (settings) ->
      @session_id = uuid.v4().toString()

      # @conn       = "tcp://"+settings.ip+":"
      # @shell_port = settings.shell_port
      # @iopub_port = settings.iopub_port
      # @hb_port    = settings.hb_port

      @conn       = "tcp://127.0.0.1:"
      @shell_port = "51575"
      @iopub_port = "56902"
      @hb_port    = "52938"

      @shell_socket = zmq.socket 'dealer'
      @iopub_socket = zmq.socket 'sub'
      @hb_socket    = zmq.socket 'req'

      @connect()
      @configure_sockets()
      @setup_hb(5000, 500)

    connect: =>
      @shell_socket.connect @conn+@shell_port
      @iopub_socket.connect @conn+@iopub_port
      @hb_socket.connect @conn+@hb_port

    configure_sockets: =>
      @shell_socket.setsockopt zmq.ZMQ_IDENTITY, Buffer(@session_id)
      @iopub_socket.setsockopt zmq.ZMQ_SUBSCRIBE, Buffer('')

    send_shell: (msg) =>
      @shell_socket.send msg

    setup_hb: (time_between_hbs, hb_wait_time) =>
      setInterval ( =>
        hb_message = Date.now()
        @hb_socket.send hb_message
        console.log "sending hb"
        @hb_socket._events = {}
        timeout = setTimeout ( ->
          alert('hb timeout')
          ), hb_wait_time
        @hb_socket.on 'message', (msg) =>
          console.log "got msg "+msg
          clearTimeout timeout if msg = hb_message
      ), time_between_hbs

    on_iopub: (cb) =>
      @iopub_socket.on 'message', cb

    on_shell: (cb) ->
      @shell_socket.on 'message', cb
