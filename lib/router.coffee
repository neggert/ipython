parse_msg = (msg) ->
  while msg[0].toString() != "<IDS|MSG>"
    msg = msg[1..]
  msg = msg[2..]
  {
    header: JSON.parse msg[0]
    prev_header: JSON.parse msg[1]
    metadata: JSON.parse msg[2]
    content: JSON.parse msg[3]
  }

module.exports =
  route = (handle, ipKernelManager, ipView, raw_msg) ->
    console.log "route"

    msg = parse_msg raw_msg
    msg_type = msg.header.msg_type

    unless msg_type of handle
      console.log "No handler for msg_type "+msg_type
      return

    handle[msg_type](msg, ipKernelManager, ipView)
