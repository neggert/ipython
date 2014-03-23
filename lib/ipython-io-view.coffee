{$$, View, EditorView} = require 'atom'
uuid = require 'node-uuid'

# View representing a single input box/output box pair

module.exports =
class IPythonIOView extends View
  @content: (input_callback) =>
    @div class: 'ipython-io', =>
      @div class: 'ipython-io-line block', outlet: 'input_div', =>
        @label outlet: "input_label", "In [ ]:"
        @subview 'input_ed', new EditorView mini: true

  initialize: ->
    @id = uuid.v4()

  on_input: (cb) =>
    @on 'core:confirm', =>
      cb "execute_request", @id, @input_ed.getText()

  make_input_noneditable: =>
    # delete the mini-editor, replace it with a div with the same style and text
    text = @input_ed.getText()
    @input_ed.remove() ## replace?
    @input_div.append $$ ->
      @div class: "editor mini editor-colors", text

  set_n: (n) =>
    @input_label.replaceWith $$ ->
      @label "In [#{n}]:"

  output: (text, n) =>
    # add an output box containing text
    @append $$ ->
      @div class: 'ipython-io-line block', =>
        @label "Out [#{n}]:"
        @div class: 'editor mini editor-colors', text

  error: (ename, evalue, n) =>
    # add an output box containing text
    @append $$ ->
      @div class: 'ipython-io-line block', =>
        @label "Error [ ]:"
        @div class: 'editor mini editor-colors', ename+": "+evalue
