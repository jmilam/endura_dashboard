class Configurations::SroReportCriteriaController < ApplicationController
	layout 'configuration'
	def index
		@report_criterias = ReportCriteria.all
		@header = "SRO Report Criteria Management"
	end

	def create
		#Because form name is different the database name, have to set criteria to form paramter.
		@report_criteria = ReportCriteria.new(criteria: report_criteria_params[:name])

		if @report_criteria.save
			flash[:notice] = "Report Criteria was successfully created"
			redirect_to configurations_sro_report_criteria_path
		else
			flash[:error] = Formatter.format_errors(@report_criteria.errors.messages)
			redirect_to configurations_sro_report_criteria_path
		end
	end

	def update
		@report_criteria = ReportCriteria.find(params[:id])
		
		if @report_criteria.update_attribute(:criteria, params[:name])
			respond_to do |format|
				format.json { render json: {success: true}}
			end
		else 
			respond_to do |format|
				format.json { render json: {success: false}}
			end
		end
	end

	def destroy
		@report_criteria = ReportCriteria.find(params[:id])

		if @report_criteria.delete
			flash[:notice] = "Report Criteria was successfully deleted"
			redirect_to configurations_sro_report_criteria_path
		else
			flash[:error] = Formatter.format_errors(@tsm.errors.messages)
			redirect_to configurations_sro_report_criteria_path
		end
	end

	private

	def report_criteria_params
		params.require(:report_criteria).permit(:name)
	end
end