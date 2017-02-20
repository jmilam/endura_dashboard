class Salesforces::SalesCallsController < ApplicationController
	def index
		start_date = params[:start_date].blank? ? (Date.today.beginning_of_week - 1.week).strftime('%Y-%m-%d') : Date.strptime(params[:start_date], "%m/%d/%Y").strftime('%Y-%m-%d')
		end_date = params[:end_date].blank? ? (Date.today.end_of_week - 1.week).strftime('%Y-%m-%d') : Date.strptime(params[:end_date], "%m/%d/%Y").strftime('%Y-%m-%d')
		
		@salesforce_request = SalesForce.new
		@response = @salesforce_request.requestAPIData(session[:token], start_date, end_date)

		@response_data = JSON.parse(@response.body)

		if session[:token].nil? 
			unless @response_data[0].nil?
				if JSON.parse(@response.body)[0]["message"] == "Session expired or invalid"
				  @token = set_salesforce_token(@salesforce_request)
				  @response = @salesforce_request.requestAPIData(@token)
					@response_data = JSON.parse(@response.body)
				end
			end
		end

		@sales_call_data = @response_data["factMap"]["T!T"]["rows"]
	end
end