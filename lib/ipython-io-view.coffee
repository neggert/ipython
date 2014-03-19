{$$, View, EditorView} = require 'atom'

# View representing a single input box/output box pair

module.exports =
class IPythonIOView extends View
  @content: (line_num, input_callback) =>
    @div class: 'ipython-io', =>
      @div class: 'ipython-io-line block', outlet: 'input_div', =>
        @label "In [#{line_num}]:"
        @subview 'input_ed', new EditorView mini: true

  initialize: (line_num, @input_callback) ->
    # register a callback for when the user hits "Enter" in the input box
    @on 'core:confirm', =>
      text = @input_ed.getText()
      @make_input_noneditable()
      @input_callback(text)

  make_input_noneditable: =>
    # delete the mini-editor, replace it with a div with the same style and text
    text = @input_ed.getText()
    @input_ed.remove() ## replace?
    @input_div.append $$ ->
      @div class: "editor mini editor-colors", text

  output: (text, line_num) =>
    # add an output box containing text
    @append $$ ->
      @div class: 'ipython-io-line block', =>
        @label "Out [#{line_num}]:"
        @div class: 'editor mini editor-colors', text
