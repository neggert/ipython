module.exports =
  'execute_reply': (msg, ipKernelManager, ipView) ->
    viewId = msg.prev_header.msg_id
    n = msg.content.execution_count
    ipView.ioViews[viewId].set_n n

    if msg.content.payload.length > 0
      ipView.ioViews[viewId].output msg.content.payload[0].text, n
