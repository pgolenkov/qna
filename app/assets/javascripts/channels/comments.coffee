App.comments = App.cable.subscriptions.create channel: "CommentsChannel", question_id: gon.question_id,
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    if data.user_id != gon.user_id
      $("##{data.commentable_type.toLowerCase()}-#{data.commentable_id}-comments").find(".comments-list").append App.utils.render("comments/comment", data)
