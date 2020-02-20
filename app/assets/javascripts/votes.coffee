# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  $('body').on 'ajax:success', '.vote-link', (e) ->
    vote = e.detail[0].vote
    message = if vote.status == 'like' then 'You like it!' else 'You dislike it!'
    $(".vote").html(message)

  voteLink = (name, status, vote) ->
    '<a data-type="json" class="vote-link" data-remote="true" rel="nofollow" data-method="post" href="/votes?status=' + status + '&amp;votable_id=' + vote.votable_id + '&amp;votable_type=' + vote.votable_type + '">' + name + '</a>'

  $('body').on 'ajax:success', '.cancel-vote-link', (e) ->
    vote = e.detail[0].vote
    $(".vote").html(voteLink('Like', 'like', vote) + voteLink('Dislike', 'dislike', vote))
