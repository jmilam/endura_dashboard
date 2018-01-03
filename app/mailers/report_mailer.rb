class ReportMailer < ApplicationMailer
	require 'net/http'
	default from: 'alerts@enduraproducts.com'
 
  def backlog_overview_email
  	@counter = 0
		@header = true
		@sub_header = false

		@body_next = false
		@header_next = true
		@new_table = false

  	mail(to: 'jasonlmilam@gmail.com', subject: 'Backlog Overview Email')
  end
end
