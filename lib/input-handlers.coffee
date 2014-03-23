ipmsg = require './ipython-messages'

module.exports =
  'execute_request': (msg_id, msg, ipKernelManager, ipView) ->
    msg = ipmsg.build_exec_request_msg msg_id, msg
    ipKernelManager.send_shell msg
    ipView.new_io()
