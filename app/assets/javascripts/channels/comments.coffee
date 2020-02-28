App.comments = App.cable.subscriptions.create channel: "CommentsChannel", question_id: gon.question_id,
  received: (data) ->
    if data.user_id != gon.user_id
      $("##{data.commentable_type.toLowerCase()}-#{data.commentable_id}-comments").find(".comments-list").append App.utils.render("comments/comment", data)
