class Salesforces::SalesCallsController < ApplicationController
	def index
		#This is the custom sales report from salesforce I created for params
		uri = URI.parse("https://na32.salesforce.com/services/data/v38.0/analytics/reports/00O38000004d1XQ")

		request = Net::HTTP::Post.new(uri, {"Conent-type" => "application/json"})
		request["Authorization"] = "Bearer 00D300000000eGS!ARkAQEbmAmlp.hZMCfSOdVEDXe6U7hGyDONHTxdDYPggh3Vtbl3ubd4Q_mxnyRPNiBKEhwskLUYiPVOXkVfru5jncQAH6Q3d"

		request.body = '{"reportMetadata": {"name": "Endura Custom Dashboard - Sales Report","id": "00O38000004d1XQ","reportFormat": "TABULAR","reportBooleanFilter": "(1OR4)AND2AND3","reportFilters": [{"column": "CUST_CREATED_DATE", "isRunPageEditable": true, "operator": "greaterOrEqual","value": "2017-01-01"},{"column": "CUST_CREATED_DATE", "isRunPageEditable": true,  "operator": "lessThan","value": "2017-01-17"}],"detailColumns": ["CUST_NAME", "Sales_Call_Report__c.Business_Plan__c", "Sales_Call_Report__c.Milestone__c", "Sales_Call_Report__c.TSM__c", "Sales_Call_Report__c.Territory_Rep__c", "Sales_Call_Report__c.Customer__c", "Sales_Call_Report__c.Purpose_of_Call__c", "Sales_Call_Report__c.Items_Discussed__c", "Sales_Call_Report__c.Account__c", "Sales_Call_Report__c.Contact__c", "Sales_Call_Report__c.Lead__c", "Sales_Call_Report__c.Follow_Up_By__c", "Sales_Call_Report__c.Follow_up_Points__c", "Sales_Call_Report__c.Status__c", "Sales_Call_Report__c.Report_Date__c"],"developerName": "Endura_Custom_Dashboard_Sales_Report","reportType": {"label"=>"Custom Object", "type"=>"CustomEntity$Sales_Call_Report__c"},"aggregates": ["RowCount"],"groupingsDown": [],"groupingsAcross": []}}'
		
		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end

		@response_data = JSON.parse(response.body)
		p @response_data["reportMetadata"]
		@sales_call_data = @response_data["factMap"]["T!T"]["rows"]

	end
end