App.answers = App.cable.subscriptions.create channel: "AnswersChannel", question_id: gon.question_id,
  connected: ->

  disconnected: ->

  received: (data) ->
    console.log(data)
    $(".answers").append App.utils.render("answer", data)
