class Reports::BacklogController < ApplicationController
	require 'csv'
	def index
		@counter = 0
		@header = true
		@sub_header = false

		@body_next = false
		@header_next = true
		@new_table = false

		ReportMailer.backlog_overview_email.deliver_now
	end

end
