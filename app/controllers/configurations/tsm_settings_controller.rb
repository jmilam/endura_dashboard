class Configurations::TsmSettingsController < ApplicationController
	layout 'configuration'
	def index
		@tsms = Tsm.all
		@header = "TSM Management"
	end

	def new
		@tsm = Tsm.new
	end

	def create
		@tsm = Tsm.new(tsm_params)
		if @tsm.save
			flash[:notice] = "TSM was successfully created"
			redirect_to configurations_tsm_settings_path
		else
			flash[:error] = Formatter.format_errors(@tsm.errors.messages)
			redirect_to configurations_tsm_settings_path
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
		@tsm = Tsm.find(params[:id])

		if @tsm.delete
			flash[:notice] = "TSM was successfully deleted"
			redirect_to configurations_tsm_settings_path
		else
			flash[:error] = Formatter.format_errors(@tsm.errors.messages)
			redirect_to configurations_tsm_settings_path
		end
	end

	private

	def tsm_params
		params.require(:tsm).permit(:name)
	end
end
