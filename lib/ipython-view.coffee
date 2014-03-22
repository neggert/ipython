{$, $$, ScrollView} = require 'atom'
IPythonIOView = require './ipython-io-view'

module.exports =
class IpythonView extends ScrollView
  @content: ->
    @div class: 'vertical',  =>
      @div outlet: 'termout', class: 'ipython padded'

  initialize: (@input_callback) ->
    super()
    atom.workspaceView.command "ipython:toggle", => @toggle()
    @io_views = {}
    @new_io()

  input_callback_view: (text, id) =>
    @new_io()
    @input_callback text, id

  new_io: =>
    v = new IPythonIOView @input_callback_view
    @io_views[v.id] = v
    @termout.append @io_views[v.id]

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
