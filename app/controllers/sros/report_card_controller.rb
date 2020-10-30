class Sros::ReportCardController < ApplicationController
	skip_before_filter :verify_authenticity_token  
	require 'csv'
	require 'net/http/post/multipart'
	def create
		email = nil
		response = nil
		report_date = Date.parse(params["t_month"]).strftime("%b '%y") unless params["t_month"].nil?
		spreadsheet = StringIO.new
		Spreadsheet.client_encoding = 'UTF-8'
		book = Spreadsheet::Workbook.new
		sheet1 = book.create_worksheet :name => "Report Card #{Date.today.strftime("%m-%d-%Y")}"
		sheet1.row(0).replace ["Employee Name", "Total Orders", "Manual orders", "Manual Lag Time (Days)", "Scaned Orders", "Scanned Lag Time (Days)", "Total Orders Complete %", "Total Lines", "Manual Lines", "Auto Lines", "Total Line Complete %", "Customer Count", "Total Order $", "Total Sro's", "Report Month"]
		
		row_count = 1

		params[:emp_report_card].each do |key, value|
			if email.nil?
				email = value["email"]
			end
			sheet1.row(row_count).replace [value["emp"], value["total_order_count"], value["man_orders"], value["man_lag_time"], value["auto_orders"], value["scan_lag_time"], value["order_perc"], value["total_lines"],
																		 value["man_lines"], value["auto_lines"], value["line_perc"], value["cust_count"], value["sro_dol_total"], value["sro_total"], value["stat_month"]]
			row_count += 1
		end

		file_loc = "public/report cards/oe/OE-Emp-Report-Card-#{Date.today.strftime("%m-%d-%Y")}.xls"
		book.write file_loc

	  req_params = {from: "oe_sro_dashboard@enduraproducts.com", to: "#{email}", subject: "OE Report Card", chart_data: {data: Formatter.from_oe_report_card(params[:emp_report_card])}}
		uri = URI("http://webapidev.enduraproducts.com/api/endura/email/order_entry/report_card")

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