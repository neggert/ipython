zmq = require 'zmq'
uuid = require 'node-uuid'

module.exports =
  class IPythonKernelManager
    constructor: (settings) ->
      @n = 0
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
      @register_callbacks()

    connect: =>
      @shell_socket.connect @conn+@shell_port
      @iopub_socket.connect @conn+@iopub_port
      @hb_socket.connect @conn+@hb_port

    configure_sockets: =>
      @shell_socket.setsockopt zmq.ZMQ_IDENTITY, Buffer(@session_id)
      @iopub_socket.setsockopt zmq.ZMQ_SUBSCRIBE, Buffer('')

    register_callbacks: =>
      @setup_hb(5000, 500)
      @iopub_socket.on 'message', @handle_output
      @shell_socket.on 'message', @handle_reply

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

    handle_reply: (reply_msg...) =>
      console.log "reply "+reply_msg

    handle_output: (output_msg...) =>
      header = JSON.parse output_msg[3]
      prev_header = JSON.parse output_msg[4]
      content = JSON.parse output_msg[6]

      msg_type = header.msg_type
      unless msg_type in ['pyout', 'pyerr']
        console.log "Got unexpected output type"
        console.log header
        console.log content
        return
      console.log "pyout"
      console.log content
      id = prev_header.msg_id
      n = parseInt content.execution_count
      text = content.data
      @output_callback text, n

    execute_command: (command, msg_id) =>
      console.log "execute_command "+command
      msg = @build_exec_request_msg msg_id, command
      @shell_socket.send msg

      # return a promise to the execution_count?
      @n += 1

    build_exec_request_msg: (msg_id, code) ->
      content = @make_command_msg_content code
      @build_full_msg 'execute_request', msg_id, content

    build_full_msg: (msg_type, msg_id, content) ->
      msg_body = @make_msg_body msg_type, msg_id, content
      body_serialized = (JSON.stringify(x) for x in msg_body)
      hmac = @make_hmac body_serialized.join('')

      msg = [
        '<IDS|MSG>'
        hmac
      ]

      msg.push body_serialized...
      msg

    make_hmac: (content) ->
      ''

    make_msg_body: (msg_type, msg_id, content) ->
      msg_id = uuid.v4()
      [
        @make_msg_header msg_id, msg_type
        {}
        {}
        content
      ]

    make_msg_header: (msg_id, msg_type) ->
      username: process.env.USER
      session: @session_id
      msg_id: msg_id
      msg_type: msg_type

    make_command_msg_content: (code) ->
      code: code
      silent: false
      store_history: true
      user_variables: []
      user_expressions: {}
      allow_stdin: true

    on_output: (@output_callback) ->
