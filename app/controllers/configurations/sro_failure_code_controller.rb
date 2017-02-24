class Configurations::SroFailureCodeController < ApplicationController
	def index
		@failure_codes = FailureCode.all
		@header = "SRO Failure Code Management"
	end
end