module.exports =
  'pyout': (msg, ipKernelManager, ipView) ->
    viewId = msg.prev_header.msg_id
    text = msg.content.data['text/plain']
    n = msg.content.execution_count
    ipView.ioViews[viewId].output text, n
  'pyerr': (msg, ipKernelManager, ipView) ->
    viewId = msg.prev_header.msg_id
    n = msg.content.execution_count
    ipView.ioViews[viewId].error msg.content.ename, msg.content.evalue, n
