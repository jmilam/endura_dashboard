class Salesforces::SalesCallsController < ApplicationController
	def index

		@tsms = Array.new
		start_date = params[:start_date].blank? ? (Date.today.beginning_of_week - 1.week).strftime('%Y-%m-%d') : Date.strptime(params[:start_date], "%m/%d/%Y").strftime('%Y-%m-%d')
		end_date = params[:end_date].blank? ? (Date.today.end_of_week - 1.week).strftime('%Y-%m-%d') : Date.strptime(params[:end_date], "%m/%d/%Y").strftime('%Y-%m-%d')
		
		@salesforce_request = SalesForce.new
		@response = @salesforce_request.requestAPIData(session[:token], start_date, end_date)

		@response_data = JSON.parse(@response.body)
		if @response_data[0].nil?
		else
			if @response_data[0]["message"] == "Session expired or invalid"
					session.delete(:token)
					@token = session[:token] = @salesforce_request.activateToken
				  @response = @salesforce_request.requestAPIData(@token)
					@response_data = JSON.parse(@response.body)
			end
		end

		@sales_call_data = @response_data["factMap"]["T!T"]["rows"]
		
		@sales_call_data.each do |value|
			@tsms.push(value["dataCells"][3]["label"]) unless @tsms.include?(value["dataCells"][3]["label"])
		end
		@tsms.sort!
	end
end