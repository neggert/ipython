{$, $$, ScrollView} = require 'atom'
IPythonIOView = require './ipython-io-view'

module.exports =
class IpythonView extends ScrollView
  @content: ->
    @div class: 'ipython padded pane-item',  =>
      @div outlet: 'termout'

  initialize: (@input_callback) ->
    super()
    @uri = 'atom://ipython'
    @ioViews = {}
    @new_io()

  new_io: =>
    v = new IPythonIOView()
    @ioViews[v.id] = v
    @termout.append @ioViews[v.id]
    v.on_input @input_callback
    v.input_ed.focus()

  # # Returns an object that can be retrieved when package is activated
  # serialize: ->
  #
  # # Tear down any state and detach
  # destroy: ->
  #   @detach()

  getTitle: -> "IPython"

  getUri: -> @uri
