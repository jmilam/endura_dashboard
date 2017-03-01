class Configurations::AnnualQuarterController < ApplicationController
	layout 'configuration'
	def index
		@quarters = [["Q1",1],["Q2",2],["Q3",3],["Q4",4]]
		@select_box_data = @quarters
		@select_placeholder = "Select Quarter"
		@quarter_weeks = WeekQuarterCount.all
		@quarters.keep_if {|q| @quarter_weeks.find_by_quarter(q[1]).nil?} 
		@quarter_weeks = @quarter_weeks.sort_by {|q| q.quarter} 
		@header = "Quarter Management"
	end

	def create
		@quarter = WeekQuarterCount.new(quarter: params[:quarter][:quarter_id], week_count: params[:week_quarter_counts][:name])
		if @quarter.save
			flash[:notice] = "Quarter was successfully created"
			redirect_to configurations_annual_quarter_index_path
		else
			flash[:error] = Formatter.format_errors(@quarter.errors.messages)
			redirect_to configurations_annual_quarter_index_path
		end
	end

	def update
		@quarter = WeekQuarterCount.find(params[:id])
		
		if @quarter.update_attribute(:week_count, params[:name])
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
		@quarter = WeekQuarterCount.find(params[:id])
		if @quarter.delete
			flash[:notice] = "Quarter was successfully deleted"
			redirect_to configurations_annual_quarter_index_path
		else
			flash[:error] = Formatter.format_errors(@quarter.errors.messages)
			redirect_to configurations_annual_quarter_index_path
		end
	end

	private

	def quarter_params
		params.require(:week_quarter_counts).permit(:name)
	end
end