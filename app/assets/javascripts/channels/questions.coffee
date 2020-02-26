App.questions = App.cable.subscriptions.create "QuestionsChannel",
  connected: ->

  disconnected: ->

  received: (data) ->
    $(".questions").append App.utils.render("question", data)
