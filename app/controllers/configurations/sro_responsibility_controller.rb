class Configurations::SroResponsibilityController < ApplicationController
	layout 'configuration'
	def index
		@responsibilities = Responsibility.all
		@header = "SRO Responsibility Management"
	end

	def create
		@responsibility = Responsibility.new(responsibility_params)

		if @responsibility.save
			flash[:notice] = "Responsibility was successfully created"
			redirect_to configurations_sro_responsibility_index_path
		else
			flash[:error] = Formatter.format_errors(@tsm.errors.messages)
			redirect_to configurations_sro_responsibility_index_path
		end
	end

	def update
		@responsibility = Responsibility.find(params[:id])
		
		if @responsibility.update_attribute(:name, params[:name])
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
		@responsibility = Responsibility.find(params[:id])

		if @responsibility.delete
				flash[:notice] = "Responsibility was successfully deleted"
			redirect_to configurations_sro_responsibility_index_path
		else
			flash[:error] = Formatter.format_errors(@tsm.errors.messages)
			redirect_to configurations_sro_responsibility_index_path
		end
	end


	private

	def responsibility_params
		params.require(:responsibility).permit(:name)
	end
end