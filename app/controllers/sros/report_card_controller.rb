class Sros::ReportCardController < ApplicationController
	skip_before_filter :verify_authenticity_token  
	require 'csv'
	require 'net/http/post/multipart'
	def create
		response = nil
		report_date = Date.parse(params["t_month"]).strftime("%b '%y") unless params["t_month"].nil?
		spreadsheet = StringIO.new
		Spreadsheet.client_encoding = 'UTF-8'
		book = Spreadsheet::Workbook.new
		sheet1 = book.create_worksheet :name => "Report Card #{Date.today.strftime("%m-%d-%Y")}"
		sheet1.row(0).replace ["Employee Name", "Total Orders", "Manual orders", "Auto Orders", "Total Orders %", "Total Lines", "Manual Lines", "Auto Lines", "Total Line %", "Customer Count", "Total Sro's", "Report Month"]
		
		row_count = 1

		params[:emp_report_card].each do |key, value|
			sheet1.row(row_count).replace [value["emp"], value["total_order_count"], value["man_orders"], value["auto_orders"], value["order_perc"], value["total_lines"],
																		 value["man_lines"], value["auto_lines"], value["line_perc"], value["cust_count"], value["sro_total"], value["stat_month"]]
			row_count += 1
		end
		file_loc = "public/report cards/oe/OE-Emp-Report-Card-#{Date.today.strftime("%m-%d-%Y")}.xls"
		book.write file_loc

	  req_params = {from: "jmilam@enduraproducts.com", to: "jmilam@enduraproducts.com", subject: "OE Report Card", chart_data: {data: Formatter.from_oe_report_card(params[:emp_report_card])}}
		uri = URI(self.api_url + "/email/order_entry/report_card")

	  File.open(file_loc) do |xls_file|
	  	req_params[:file] = UploadIO.new(xls_file, "application/vnd.ms-excel", "test.xls")
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