class Salesforces::SalesCallsController < ApplicationController
	def index
		@salesforce_request = SalesForce.new
		
		@sales_reps = SalesRep.all.includes(:tsm)
		begin_date = params[:start_date].blank? ? Date.today : Date.strptime(params[:end_date], "%m/%d/%Y")
		end_date = params[:end_date].blank? ? Date.today : Date.strptime(params[:end_date], "%m/%d/%Y")
		@Q1 = @salesforce_request.Q1(begin_date, end_date)
		@Q2 = @salesforce_request.Q2(begin_date, end_date)
		@Q3 = @salesforce_request.Q3(begin_date, end_date)
		@Q4 = @salesforce_request.Q4(begin_date, end_date)

		@tsm_sales_call_details = Hash.new
		@tsm_sales_call_details[:all_calls] =  {all_calls: {Q1: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q2: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q3: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q4: {bus_plan: 0, non_bus_plan: 0, total: 0}, YTD: {bus_plan: 0, non_bus_plan: 0, total: 0}}}
		@bus_plan = 0
		@non_bus_plan = 0

		start_date = params[:start_date].blank? ? (Date.today.beginning_of_year).strftime('%Y-%m-%d') : Date.strptime(params[:start_date], "%m/%d/%Y").strftime('%Y-%m-%d')
		end_date = params[:end_date].blank? ? (Date.today.end_of_year).strftime('%Y-%m-%d') : Date.strptime(params[:end_date], "%m/%d/%Y").strftime('%Y-%m-%d')

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
			quarter = SalesForce.addToQuarter(value["dataCells"].last["value"])

			if @tsm_sales_call_details[value["dataCells"][3]["label"]].nil?
				@tsm_sales_call_details[value["dataCells"][3]["label"]] = {value["dataCells"][4]["label"] => {Q1: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q2: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q3: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q4: {bus_plan: 0, non_bus_plan: 0, total: 0}, YTD: {bus_plan: 0, non_bus_plan: 0, total: 0}}, Total: {Q1: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q2: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q3: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q4: {bus_plan: 0, non_bus_plan: 0, total: 0}, YTD: {bus_plan: 0, non_bus_plan: 0, total: 0}}}
				@tsm_sales_call_details[value["dataCells"][3]["label"]][value["dataCells"][4]["label"]] = SalesForce.part_of_business_plan?(value["dataCells"][1]["label"], @tsm_sales_call_details[value["dataCells"][3]["label"]][value["dataCells"][4]["label"]], quarter.to_sym)
				@tsm_sales_call_details[value["dataCells"][3]["label"]][value["dataCells"][4]["label"]][:Total] = SalesForce.part_of_business_plan?(value["dataCells"][1]["label"], @tsm_sales_call_details[value["dataCells"][3]["label"]][:Total], quarter.to_sym)
				@tsm_sales_call_details[:all_calls][:all_calls] = SalesForce.part_of_business_plan?(value["dataCells"][1]["label"], @tsm_sales_call_details[:all_calls][:all_calls], quarter.to_sym)
			else
				if @tsm_sales_call_details[value["dataCells"][3]["label"]][value["dataCells"][4]["label"]].nil?
					@tsm_sales_call_details[value["dataCells"][3]["label"]][value["dataCells"][4]["label"]] = {Q1: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q2: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q3: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q4: {bus_plan: 0, non_bus_plan: 0, total: 0} , YTD: {bus_plan: 0, non_bus_plan: 0, total: 0}, Total: {Q1: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q2: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q3: {bus_plan: 0, non_bus_plan: 0, total: 0}, Q4: {bus_plan: 0, non_bus_plan: 0, total: 0}, YTD: {bus_plan: 0, non_bus_plan: 0, total: 0}}}
				end
				@tsm_sales_call_details[value["dataCells"][3]["label"]][value["dataCells"][4]["label"]] = SalesForce.part_of_business_plan?(value["dataCells"][1]["label"], @tsm_sales_call_details[value["dataCells"][3]["label"]][value["dataCells"][4]["label"]], quarter.to_sym)
				@tsm_sales_call_details[value["dataCells"][3]["label"]][value["dataCells"][4]["label"]][:Total] = SalesForce.part_of_business_plan?(value["dataCells"][1]["label"], @tsm_sales_call_details[value["dataCells"][3]["label"]][:Total], quarter.to_sym)
				@tsm_sales_call_details[:all_calls][:all_calls] = SalesForce.part_of_business_plan?(value["dataCells"][1]["label"], @tsm_sales_call_details[:all_calls][:all_calls], quarter.to_sym)
			end
		end

		@tsm_sales_call_perc_detail = SalesForce.calculate_perc(@tsm_sales_call_details.deep_dup, @sales_reps)

	end
end