# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'ready', ->

	$('select#DeptSearch').on 'change', ->
		if $(this).val() == ""
		  $.each $('.departments tbody tr'), (index, row) ->
		  	$(this).removeClass 'hidden'
		else
		  $.each $('.departments tbody tr'), (index, row) ->
			  if $(this).children('td:eq(0)').text() == $('select#DeptSearch').val()
			    $(this).removeClass 'hidden'
			  else
			    $(this).addClass 'hidden'
	  return
