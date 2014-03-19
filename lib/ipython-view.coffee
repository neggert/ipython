{$, $$, ScrollView} = require 'atom'
IPythonIOView = require './ipython-io-view'

module.exports =
class IpythonView extends ScrollView
  @content: ->
    @div class: 'vertical',  =>
      @div "The Ipython package is Alive! It's ALIVE!"
      @div outlet: 'termout', class: 'ipython'

  initialize: (@input_callback) ->
    super()
    atom.workspaceView.command "ipython:toggle", => @toggle()
    @io_views = []
    @new_io(1)

  input_callback_view: (text) =>
    @new_io(@io_views.length)
    @input_callback text

  new_io: (num) =>
    @io_views[num] = new IPythonIOView(num, @input_callback_view)
    @termout.append @io_views[num]

  # # Returns an object that can be retrieved when package is activated
  # serialize: ->
  #
  # # Tear down any state and detach
  # destroy: ->
  #   @detach()

  toggle: ->
    console.log "IpythonView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.appendToRight(this)
