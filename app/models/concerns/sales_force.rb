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
end