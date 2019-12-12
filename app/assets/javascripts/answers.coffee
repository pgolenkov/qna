# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  $('.answers').on 'click', '.edit-answer-link', (e) ->
    e.preventDefault()
    $(this).addClass('hidden')
    answerId = $(this).data('answerId')
    $("#answer-#{answerId} form").removeClass('hidden')
