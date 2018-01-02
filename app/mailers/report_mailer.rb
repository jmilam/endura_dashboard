class ReportMailer < ApplicationMailer
	require 'net/http'
	default from: 'alerts@enduraproducts.com'
 
  def backlog_overview_email
  	mail(to: 'jasonlmilam@gmail.com', subject: 'Backlog Overview Email')
  end
end
