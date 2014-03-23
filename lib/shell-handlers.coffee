module.exports =
  'execute_reply': (msg, ipKernelManager, ipView) ->
    viewId = msg.prev_header.msg_id
    n = msg.content.execution_count
    ipView.ioViews[viewId].set_n n
