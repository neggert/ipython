module.exports =
  parse_msg: (msg) ->
    header = JSON.parse msg[2]
    prev_header = JSON.parse msg[3]
    content = JSON.parse msg[5]
    [header, prev_header, content]

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
