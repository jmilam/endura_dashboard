class Salesforces::SalesCallsController < ApplicationController
	def index
		@Q1 =  "#{Date.today.beginning_of_year.strftime("%m/%d/%y")} - #{(Date.today.beginning_of_year + 2.months).end_of_month.strftime("%m/%d/%y")}"
		@Q2 = "#{(Date.today.beginning_of_year + 3.months).strftime("%m/%d/%y")} - #{(Date.today.beginning_of_year + 5.months).end_of_month.strftime("%m/%d/%y")}"
		@Q3 = "#{(Date.today.beginning_of_year + 6.months).strftime("%m/%d/%y")} - #{(Date.today.beginning_of_year + 8.months).end_of_month.strftime("%m/%d/%y")}"
		@Q4 = "#{(Date.today.beginning_of_year + 9.months).strftime("%m/%d/%y")} - #{(Date.today.beginning_of_year + 11.months).end_of_month.strftime("%m/%d/%y")}"
		@tsm_sales_call_details = Hash.new
		@bus_plan = 0
		@non_bus_plan = 0

		@tsms = Array.new
		start_date = params[:start_date].blank? ? (Date.today.beginning_of_year).strftime('%Y-%m-%d') : Date.strptime(params[:start_date], "%m/%d/%Y").strftime('%Y-%m-%d')
		end_date = params[:end_date].blank? ? (Date.today.end_of_year).strftime('%Y-%m-%d') : Date.strptime(params[:end_date], "%m/%d/%Y").strftime('%Y-%m-%d')
		
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
			if @tsm_sales_call_details[value["dataCells"][3]["label"]].nil?
				@tsm_sales_call_details[value["dataCells"][3]["label"]] = {bus_plan: 0, non_bus_plan: 0}
				@tsm_sales_call_details[value["dataCells"][3]["label"]] = SalesForce.part_of_business_plan?(value["dataCells"][1]["label"], @tsm_sales_call_details[value["dataCells"][3]["label"]])
			else
				@tsm_sales_call_details[value["dataCells"][3]["label"]] = SalesForce.part_of_business_plan?(value["dataCells"][1]["label"], @tsm_sales_call_details[value["dataCells"][3]["label"]])
			end
			
			@tsms.push(value["dataCells"][3]["label"]) unless @tsms.include?(value["dataCells"][3]["label"])
		end
		@tsms.sort!

		p @tsm_sales_call_details
	end
end