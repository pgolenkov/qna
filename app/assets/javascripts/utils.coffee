App = window.App = {}

App.utils =
  render: (template, data) ->
    JST["templates/#{template}"](data)
