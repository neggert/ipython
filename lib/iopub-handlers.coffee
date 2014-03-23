module.exports =
  'pyout': (msg, ipKernelManager, ipView) ->
    viewId = msg.prev_header.msg_id
    text = msg.content.data['text/plain']
    n = msg.content.execution_count
    ipView.ioViews[viewId].output text, n
