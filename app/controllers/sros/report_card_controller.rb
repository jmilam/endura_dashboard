class Sros::ReportCardController < ApplicationController
	skip_before_filter :verify_authenticity_token  
	require 'csv'
	def create
		params[:emp_report_card]
		report_date = Date.parse(params["t_month"]).strftime("%b '%y") unless params["t_month"].nil?
		spreadsheet = StringIO.new
		Spreadsheet.client_encoding = 'UTF-8'
		book = Spreadsheet::Workbook.new
		sheet1 = book.create_worksheet :name => params[:emp_name].to_s
		sheet1.row(0).replace ["Employee Name", "Total Orders", "Manual orders", "Auto Orders", "Total Orders %", "Total Lines", "Manual Lines", "Auto Lines", "Total Line %", "Customer Count", "Total Sro's", "Report Month"]
		
		row_count = 1

		params[:emp_report_card].each do |key, value|
			sheet1.row(row_count).replace [value["emp"], value["total_order_count"], value["man_orders"], value["auto_orders"], value["order_perc"], value["total_lines"],
																		 value["man_lines"], value["auto_lines"], value["line_perc"], value["cust_count"], value["sro_total"], value["stat_month"]]
			row_count += 1
		end
		#sheet1.row(1).replace [params["t_userid"], (params["t_edi_ord"] + params["t_scn_ord"] + params["t_man_ord"]), params["t_man_ord"],(params["t_edi_ord"] + params["t_scn_ord"]),params["order_percent"], (params["t_edi_line"] + params["t_scn_line"] + params["t_man_line"]),params["t_man_line"], (params["t_edi_line"] + params["t_scn_line"]),params["line_percent"], params["t_cust"],(params["t_edi_sro"] + params["t_scn_sro"] + params["t_man_sro"]), report_date]

		book.write "public/report cards/oe/OE-Emp-Report-Card-#{Date.today.strftime("%m-%d-%Y")}.xls"
		
	end
end