# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  $('body').on 'ajax:success', '.vote-link', (e) ->
    vote = e.detail[0].vote
    message = if vote.status == 'like' then 'You like it!' else 'You dislike it!'
    $(".vote").html(message)
