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

	def Q1(begin_date, end_date)
		"#{begin_date.beginning_of_year.strftime("%m/%d/%y")} - #{(end_date.beginning_of_year + 2.months).end_of_month.strftime("%m/%d/%y")}"
	end
	def Q2(begin_date, end_date)
		"#{(begin_date.beginning_of_year + 3.months).strftime("%m/%d/%y")} - #{(end_date.beginning_of_year + 5.months).end_of_month.strftime("%m/%d/%y")}"
	end
	def Q3(begin_date, end_date)
		"#{(begin_date.beginning_of_year + 6.months).strftime("%m/%d/%y")} - #{(end_date.beginning_of_year + 8.months).end_of_month.strftime("%m/%d/%y")}"
	end
	def Q4(begin_date, end_date)
		"#{(begin_date.beginning_of_year + 9.months).strftime("%m/%d/%y")} - #{(end_date.beginning_of_year + 11.months).end_of_month.strftime("%m/%d/%y")}"
	end

	def self.part_of_business_plan?(bus_plan, data_hash, quarter)
		if bus_plan == "Yes"
			data_hash[quarter][:bus_plan] += 1
		else 
			data_hash[quarter][:non_bus_plan] += 1
		end
		data_hash[quarter][:total] += 1
		data_hash
	end

	def self.addToQuarter(date)
		if SalesForce.isQ1?(date)
			"Q1"
		elsif SalesForce.isQ2?(date)
			"Q2"
		elsif SalesForce.isQ3?(date)
			"Q3"
		elsif SalesForce.isQ4?(date)
			"Q4"
		else
			"Not Any"
		end
	end

	def self.isQ1?(date)
		q_begin = Date.parse(date).beginning_of_year
		q_end = (Date.parse(date).beginning_of_year + 2.months).end_of_month
		Date.parse(date) >= q_begin && Date.parse(date) <= q_end
	end

	def self.isQ2?(date)
		q_begin = (Date.parse(date).beginning_of_year + 3.months)
		q_end = (Date.parse(date).beginning_of_year + 5.months).end_of_month
		Date.parse(date) >= q_begin && Date.parse(date) <= q_end
	end

	def self.isQ3?(date)
		q_begin = (Date.parse(date).beginning_of_year + 6.months)
		q_end = (Date.parse(date).beginning_of_year + 8.months).end_of_month
		Date.parse(date) >= q_begin && Date.parse(date) <= q_end
	end

	def self.isQ4?(date)
		q_begin = (Date.parse(date).beginning_of_year + 9.months)
		q_end = (Date.parse(date).beginning_of_year + 11.months).end_of_month
		Date.parse(date) >= q_begin && Date.parse(date) <= q_end
	end

	def self.calculate_perc(data_hash)
		data_hash.each do |tsms, rep_hash|
			rep_hash.each do |key, value|
				value = self.calc_quarter("Q1", value)
				value = self.calc_quarter("Q2", value)
				value = self.calc_quarter("Q3", value)
				value = self.calc_quarter("Q4", value)
			end
		end
		data_hash
	end

	def self.calc_quarter(quarter, value)
		bus_perc = self.convert_to_perc(value[quarter.to_sym][:total], value[quarter.to_sym][:bus_plan])
		non_bus_perc = self.convert_to_perc(value[quarter.to_sym][:total], value[quarter.to_sym][:non_bus_plan])
		value[quarter.to_sym][:bus_plan] = bus_perc
		value[quarter.to_sym][:non_bus_plan] = non_bus_perc
		value[quarter.to_sym][:total] = 0
	
		value
	end

	def self.convert_to_perc(total, n)
		if total == 0
	  	0
	  else 
	  	((n.to_f / total) * 100).round(1)
	  end
	 end
end