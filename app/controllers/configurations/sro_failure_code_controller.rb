class Configurations::SroFailureCodeController < ApplicationController
	layout 'configuration'
	def index
		@select_box_data = Responsibility.all.includes(:failure_codes).map {|r| [r.name, r.id]}
		@select_placeholder = "Select Responsibility.."
		@failure_codes = FailureCode.all.includes(:responsibility)
		@header = "SRO Failure Code Management"
	end

	def create
		@responsibility = Responsibility.find(params[:responsibility][:responsibility_id])
		@failure_code = @responsibility.failure_codes.new(failure_code_params)

		if @failure_code.save
			flash[:notice] = "Failure Code was successfully created"
			redirect_to configurations_sro_failure_code_index_path
		else
			flash[:error] = Formatter.format_errors(@report_criteria.errors.messages)
			redirect_to configurations_sro_failure_code_index_path
		end
	end

	def update 
		@failure_code =  FailureCode.find(params[:id])

		if @failure_code.update_attribute(:name, params[:name])
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
		@failure_code = FailureCode.find(params[:id])
		if @failure_code.delete
			flash[:notice] = "Failure Code was successfully deleted"
			redirect_to configurations_sro_failure_code_index_path
		else
			flash[:error] = Formatter.format_errors(@report_criteria.errors.messages)
			redirect_to configurations_sro_failure_code_index_path
		end
	end

	private

	def failure_code_params
		params.require(:failure_code).permit(:name)
	end
end