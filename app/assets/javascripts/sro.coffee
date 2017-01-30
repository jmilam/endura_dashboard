# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready', ->
  hiddenReports = [
    '#ByResponsibility'
    '#ByCustomer'
    '#BySiteCustomer'
    '#BySiteReason'
    '#BySiteItem'
    '#ByFailureCode'
    '#BySiteReasonPeriod'
  ]

  id = ''

  $('select#Criteria').on 'change', ->
  	$.each hiddenReports, (idx, s)->
  	  id = s
  	  $(id).css 'display', 'none'

  	switch $(this).val()
  	  when 'Responsibility'
  	    $('#ByResponsibility').css 'display', 'block'
  	  when 'Customer'
  	    $('#ByCustomer').css 'display', 'block'
  	  when 'Site & Customer'
  	    $('#BySiteCustomer').css 'display', 'block'
  	  when 'Site & Reason'
  	    $('#BySiteReason').css 'display', 'block'
      when 'Site & Item'
        $('#BySiteItem').css 'display', 'block'
      when 'Failure Code'
        $('#ByFailureCode').css 'display', 'block'
      when 'Site, Reason & Period'
        $('#BySiteReasonPeriod').css 'display', 'block'
  	  else
  	    console.log $(this).val()
  	return
