$ ->
  $('.datepicker').datepicker
    format: 'yyyy/mm/dd'

  $("#new_task_container").on "shown", ->
    $('#new-task-link').fadeOut(250)

  $("#new_task_container").on "hidden", ->
    $('#new-task-link').fadeIn(250)

  if $(".alert-error")[0]?
    $("#new_task_container").collapse('show')

  $(':checkbox').change ->
    status_url = $(@).attr('status_url')
    status = $(@).is(':checked')
    sendDoneStatus(status_url, status)

sendDoneStatus = (status_url, status) ->
  $.ajax
    type: "PUT"
    url: status_url
    data: {task: {done: status}}
