class Configurations::SroReportCriteriaController < ApplicationController
	def index
		@report_criterias = ReportCriteria.all
		@header = "SRO Report Criteria Management"
	end
end