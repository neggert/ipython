{$, $$, ScrollView} = require 'atom'
IPythonIOView = require './ipython-io-view'

module.exports =
class IpythonView extends ScrollView
  @content: ->
    @div class: 'padded pane-item',  =>
      @div outlet: 'termout', class: 'ipython'

  initialize: (@input_callback) ->
    super()
    @uri = 'atom://ipython'
    @io_views = {}
    @new_io()

  new_io: =>
    v = new IPythonIOView @input_callback
    @io_views[v.id] = v
    @termout.append @io_views[v.id]
    v.input_ed.focus()

  # # Returns an object that can be retrieved when package is activated
  # serialize: ->
  #
  # # Tear down any state and detach
  # destroy: ->
  #   @detach()

  getTitle: -> "IPython"

  getUri: -> @uri
