class Configurations::RepSettingsController < ApplicationController
	def index
		@sales_reps = SalesRep.all.includes(:tsm)
		@tsms = Tsm.all.collect {|tsm| [ tsm.name, tsm.id] }.uniq.sort
		@header = "Sales Rep Management"
	end

	def new
		@tsm = Tsm.new
	end

	def create
		if params[:sales_rep][:tsm_id].empty?
			flash[:error] = ["Sales Rep TSM has to be selected."]
			redirect_to configurations_rep_settings_path
		else
			@sales_rep = Tsm.find(params[:sales_rep][:tsm_id]).sales_reps.new(sale_rep_params)
			if @sales_rep.save
				flash[:notice] = "Sales rep was successfully created"
				redirect_to configurations_rep_settings_path
			else
				flash[:error] = Formatter.format_errors(@sales_rep.errors.messages)
				redirect_to configurations_rep_settings_path
			end
		end
	end

	def update
		@tsm = Tsm.find(params[:id])
		
		if @tsm.update_attribute(:name, params[:name])
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
		@sales_rep = SalesRep.find(params[:id])

		if @sales_rep.delete
			flash[:notice] = "TSM was successfully deleted"
			redirect_to configurations_rep_settings_path
		else
			flash[:error] = Formatter.format_errors(@sales_rep.errors.messages)
			redirect_to configurations_rep_settings_path
		end
	end

	private

	def sale_rep_params
		params.require(:sales_rep).permit(:name, :personnel_count, :tsm_id)
	end
end