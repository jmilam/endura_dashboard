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
			data_hash[:YTD][:bus_plan] += 1
		else 
			data_hash[quarter][:non_bus_plan] += 1
			data_hash[:YTD][:non_bus_plan] += 1
		end
		data_hash[quarter][:total] += 1
		data_hash[:YTD][:total] += 1
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

	def self.tsm_exist?(tsms, tsm_name)
		return_val = Object.new

		tsms.each do |tsm|
			if tsm_name.match(tsm.name).nil? 
				next
			else
				return_val = tsm_name.match(tsm.name)[0] 
				break
			end
		end

		return_val
	end

	def self.calculate_perc(data_hash, sales_reps)
		tsms =  Tsm.all.includes(:sales_reps)
		data_hash.each do |tsm, rep_hash|
			rep_hash.each do |key, value|
				if key.to_sym == :Total
					tsm_name = self.tsm_exist?(tsms, tsm)
					if tsm_name.class == String 
						tsm_reps = Tsm.find_by_name(tsm_name).sales_reps
						unless tsm_reps.empty?
							rep_count = tsm_reps.inject(0) {|sum, rep| sum += rep.personnel_count}
							rep = {"tsm_total": {personnel_count: rep_count}}
						end
					end
				else
					rep = sales_reps.find_by_name(key)
				end
				
				value = self.calc_quarter("Q1", value, rep)
				value = self.calc_quarter("Q2", value, rep)
				value = self.calc_quarter("Q3", value, rep)
				value = self.calc_quarter("Q4", value, rep)
				value = self.calc_quarter("YTD", value, rep)
			end
		end
		data_hash
	end

	def self.calc_quarter(quarter, value, rep)
		quarters = WeekQuarterCount.all
		
		bus_perc = self.convert_to_perc(value[quarter.to_sym][:total], value[quarter.to_sym][:bus_plan])
		non_bus_perc = self.convert_to_perc(value[quarter.to_sym][:total], value[quarter.to_sym][:non_bus_plan])
		value[quarter.to_sym][:bus_plan] = bus_perc
		value[quarter.to_sym][:non_bus_plan] = non_bus_perc

		if rep.nil?
			value[quarter.to_sym][:total] = 0.to_f
		else
			if rep[:tsm_total].nil?
				quarter_query = quarter == "YTD" ? Date.today.strftime("%U").to_i : quarters.find_by_quarter(quarter.match(/\d/)[0].to_i)
				if quarter_query.class == Fixnum
					value[quarter.to_sym][:total] = ((value[quarter.to_sym][:total] / rep.personnel_count.to_f) / quarter_query).round(2) unless quarter_query.nil?
				else
					value[quarter.to_sym][:total] = ((value[quarter.to_sym][:total] / rep.personnel_count.to_f) / quarter_query.week_count).round(2) unless quarter_query.nil?
				end
				#value[:YTD][:total] = ((value[:YTD][:total] / rep.personnel_count.to_f) / quarters.inject(0) {|sum, n| sum += n.week_count}).round(2) 
			else
				quarter_query = quarter == "YTD" ? Date.today.strftime("%U").to_i : quarters.find_by_quarter(quarter.match(/\d/)[0].to_i)
				if quarter_query.class == Fixnum
					value[quarter.to_sym][:total] = ((value[quarter.to_sym][:total] / rep[:tsm_total][:personnel_count].to_f) / quarter_query).round(2) unless quarter_query.nil?
				else
					value[quarter.to_sym][:total] = ((value[quarter.to_sym][:total] / rep[:tsm_total][:personnel_count].to_f) / quarter_query.week_count).round(2) unless quarter_query.nil?
				end
				#value[:YTD][:total] = ((value[:YTD][:total] / rep[:tsm_total][:personnel_count].to_f) / quarters.inject(0) {|sum, n| sum += n.week_count}).round(2) 
			end
		end

		value
	end

	def self.convert_to_perc(total, n)
		if total == 0
	  	0
	  else 
	  	((n.to_f / total) * 100).round(1)
	  end
	end

	def self.cell_color(value, type)
		dec = value / 100
		case type
		when "perc"
			if dec >= 0.7
				"success"
			elsif dec >= 0.5 && dec <= 0.69
				"warning"
			elsif dec < 0.5
				"danger"
			else
			end
		when "decimal"
			
			if value > 3.99
				"success"
			elsif value < 3 || value < 4 || value < 2
				"danger"
			elsif value > 3 && value < 5
				"warning"
			end

			if value > 3.99
				if (3..6).include?(value)
				  "warning"
				else 
					"success"
				end
			elsif value < 3.99
				if (2..5).include?(value)
				  "warning"
				else 
					"danger"
				end
			end
		end
	end
end