class Salesforces::DataExportController < ApplicationController
	skip_before_filter :verify_authenticity_token  
	require 'csv'
	require 'net/http/post/multipart'
	
	def create
		response = nil
		# report_date = Date.parse(params["t_month"]).strftime("%b '%y") unless params["t_month"].nil?
		start_date = params[:start_date].nil? ? (Date.today.beginning_of_week - 1.week).strftime('%Y-%m-%d') : Date.strptime(params[:start_date], "%m/%d/%Y").strftime('%Y-%m-%d')
		end_date = params[:end_date].nil? ? (Date.today.end_of_week - 1.week).strftime('%Y-%m-%d') : Date.strptime(params[:end_date], "%m/%d/%Y").strftime('%Y-%m-%d')
		spreadsheet = StringIO.new
		Spreadsheet.client_encoding = 'UTF-8'
		book = Spreadsheet::Workbook.new
		sheet1 = book.create_worksheet :name => "Sales Calls"
		sheet1.row(0).replace ["Salesforce Id", "Business Plan", "Milestone", "TSM", "Territory/Rep", "Customer", "Call Purpose", "Items Discussed", "Account", "Contact", "Lead", "Follow Up By", "Follow Up Points", "Status", "Report Date"]
		
		@salesforce_request = SalesForce.new
		@response = @salesforce_request.requestAPIData(session[:token], start_date, end_date)

		@response_data = JSON.parse(@response.body)["factMap"]["T!T"]["rows"]

		row_count = 1

		@response_data.each do |data|
			value = data["dataCells"]
			sheet1.row(row_count).replace [value[0]["label"],value[1]["label"],value[2]["label"],value[3]["label"],value[4]["label"],value[5]["label"],value[6]["label"],value[7]["label"],
																		 value[8]["label"],value[9]["label"],value[10]["label"],value[11]["label"],value[12]["label"],value[13]["label"],value[14]["label"],]
			row_count += 1
		end
		file_loc = "public/salesforce_export/Salesforce-SalesCall-Export-#{Date.today.strftime("%m-%d-%Y")}.xls"
		book.write file_loc

	  req_params = {from: "salesforce_export@enduraproducts.com", to: "#{params[:email]}", subject: "Salesforce Export"}
		uri = URI(self.api_url + "/email/salesforce/export")

	  File.open(file_loc) do |xls_file|
	  	req_params[:file] = UploadIO.new(xls_file, "application/vnd.ms-excel", "salesforce_export.xls")
		  req = Net::HTTP::Post::Multipart.new uri.path, req_params
		  response = Net::HTTP.start(uri.host, uri.port) do |http|
		    http.request(req)
		  end
		end

		File.delete(file_loc)
		
		respond_to do |format|
			format.json {render json: response.body}
		end
	end
end