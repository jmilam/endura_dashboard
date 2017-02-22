class SalesForce
	require 'net/http'
	require 'json'
	attr_accessor :token

	def requestAPIData(token=nil, start_date=(Date.today.beginning_of_week - 1.week).strftime('%Y-%m-%d'), end_date=(Date.today.end_of_week - 1.week).strftime('%Y-%m-%d'))
		uri = URI.parse("https://na32.salesforce.com/services/data/v38.0/analytics/reports/00O38000004d1XQ")
		request = Net::HTTP::Post.new(uri, {"Conent-type" => "application/json"})
		request["Authorization"] = "Bearer #{token}"
		request['Content-Type'] = 'application/json'

		request.body = '{"reportMetadata": {"reportBooleanFilter": "(1 AND 2)","scope" : "organization","reportFilters": [{"value": "' +  "#{start_date}" + '","operator": "greaterOrEqual","column": "CUST_CREATED_DATE"},{"column": "CUST_CREATED_DATE","operator": "lessThan","value": "' + "#{end_date}" + '"}]}}'
		
		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
	end

	def activateToken
		uri = URI.parse("https://login.salesforce.com/services/oauth2/token")
		request = Net::HTTP::Post.new(uri)
		request.set_form_data("grant_type" => "password", "client_id" => "3MVG99OxTyEMCQ3ixdsNs7NpGBNiKIh6WRaX8e4k2G_oTCm4ZTZoimxEuBrPtfOdnUnB.foSNjeH1MyN_zokn", "client_secret" => "1947710736335721568", "username" => "sfadmin@enduraproducts.com", "password" => "sf4mfg")

		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end

		@token = JSON.parse(response.body)["access_token"]
	end

	def self.part_of_business_plan?(bus_plan, data_hash)
		if bus_plan == "Yes"
			data_hash[:bus_plan] += 1
		else 
			data_hash[:non_bus_plan] += 1
		end
		data_hash
	end

	def self.addToQuarter(date)
		if SalesForce.Q1(date)
			p "Q1"
		elsif SalesForce.Q2(date)
			p "Q2"
		elsif SalesForce.Q3(date)
			p "Q3"
		elsif SalesForce.Q4(date)
			p "Q4"
		else
			p "Not Any"
		end
	end

	def self.Q1(date)
		q_begin = Date.today.beginning_of_year
		q_end = (Date.today.beginning_of_year + 2.months).end_of_month
		Date.parse(date) >= q_begin && Date.parse(date) <= q_end
	end

	def self.Q2(date)
		q_begin = (Date.today.beginning_of_year + 3.months)
		q_end = (Date.today.beginning_of_year + 5.months).end_of_month
		Date.parse(date) >= q_begin && Date.parse(date) <= q_end
	end

	def self.Q3(date)
		q_begin = (Date.today.beginning_of_year + 6.months)
		q_end = (Date.today.beginning_of_year + 8.months).end_of_month
		Date.parse(date) >= q_begin && Date.parse(date) <= q_end
	end

	def self.Q4(date)
		q_begin = (Date.today.beginning_of_year + 9.months)
		q_end = (Date.today.beginning_of_year + 11.months).end_of_month
		Date.parse(date) >= q_begin && Date.parse(date) <= q_end
	end
end