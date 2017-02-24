class Configurations::SroResponsibilityController < ApplicationController
	def index
		@responsibilities = Responsibility.all
		@header = "SRO Responsibility Management"
	end
end