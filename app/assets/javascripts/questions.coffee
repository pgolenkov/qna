# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  $('.question').on 'click', '.edit-question-link', (e) ->
    e.preventDefault()
    $(this).addClass('hidden')
    $(".question form").removeClass('hidden')
