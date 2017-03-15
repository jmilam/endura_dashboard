class Salesforces::DataExportController < ApplicationController
	skip_before_filter :verify_authenticity_token  
	require 'csv'
	require 'net/http/post/multipart'
	
	def create
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

		total_background = Spreadsheet::Format.new :color=> :white, :pattern_fg_color => :grey, :pattern => 1
		total_background_w_right_border = Spreadsheet::Format.new :color=> :white, :pattern_fg_color => :grey, :pattern => 1, right: :medium
		total_background_w_left_border = Spreadsheet::Format.new :color=> :white, :pattern_fg_color => :grey, :pattern => 1, left: :medium
		header_border = Spreadsheet::Format.new top: :medium, left: :medium, right: :medium, align: :center
		sub_header = Spreadsheet::Format.new left: :medium, right: :medium
		right_border = Spreadsheet::Format.new right: :medium
		right_border_center = Spreadsheet::Format.new right: :medium, bottom: :thin, align: :center
		left_border = Spreadsheet::Format.new left: :medium
		center = Spreadsheet::Format.new align: :center, bottom: :thin
		header_center = Spreadsheet::Format.new align: :center, vertical_align: :middle
		table_background = Spreadsheet::Format.new :color=> :black, :pattern_fg_color => :xls_color_36, :pattern => 1,  bottom: :medium, top: :medium
		table_background_w_right_border = Spreadsheet::Format.new :color=> :black, :pattern_fg_color => :xls_color_36, :pattern => 1, right: :medium, bottom: :medium, top: :medium
		table_background_w_left_border = Spreadsheet::Format.new :color=> :black, :pattern_fg_color => :xls_color_36, :pattern => 1, left: :medium, bottom: :medium, top: :medium
		warning_background = Spreadsheet::Format.new color: :black, pattern_fg_color: :xls_color_35, pattern: 1, bottom: :thin, left: :thin, top: :thin, right: :thin
		success_background = Spreadsheet::Format.new color: :black, pattern_fg_color: :xls_color_34, pattern: 1, bottom: :thin, left: :thin, top: :thin, right: :thin
		danger_background = Spreadsheet::Format.new color: :black, pattern_fg_color: :xls_color_21, pattern: 1, bottom: :thin, left: :thin, top: :thin, right: :thin
		warning_background_border_right = Spreadsheet::Format.new color: :black, pattern_fg_color: :xls_color_35, pattern: 1, bottom: :thin, left: :thin, top: :thin, right: :medium
		success_background_border_right = Spreadsheet::Format.new color: :black, pattern_fg_color: :xls_color_34, pattern: 1, bottom: :thin, left: :thin, top: :thin, right: :medium
		danger_background_border_right = Spreadsheet::Format.new color: :black, pattern_fg_color: :xls_color_21, pattern: 1, bottom: :thin, left: :thin, top: :thin, right: :medium
		background = {danger: danger_background, warning: warning_background, success: success_background}
		background_border_right = {danger: danger_background_border_right, warning: warning_background_border_right, success: success_background_border_right}
		
		row_count = 0
		Spreadsheet.client_encoding = 'UTF-8'
		book = Spreadsheet::Workbook.new
		sheet1 = book.create_worksheet :name => "Sales Call Totals"
		sheet1.row(row_count).replace ["Sales Call Report Summary: #{Date.today.strftime('%Y')}"]
		sheet1.merge_cells row_count, 0, row_count + 1, 15
		sheet1.row(row_count).set_format(0, header_center)
		row_count += 2
		#Added extra spaces due to how the spreadsheet gem handles merging these files
		sheet1.row(row_count).replace ["", "#{@Q1}", "", "","#{@Q2}", "", "", "#{@Q3}", "", "", "#{@Q4}", "", "", "Year to Date", "", ""]
		0.upto(15) do |num|
			sheet1.row(row_count).set_format(num, header_border)
		end

		merge_cells(sheet1, row_count)
		row_count += 1

		sheet1.row(row_count).replace ["", "Bus Plan", "Non BP", "Total", "Bus Plan", "Non BP", "Total", "Bus Plan", "Non BP", "Total", "Bus Plan", "Non BP", "Total", "Bus Plan", "Non BP", "Total"]
		sheet1.row(row_count).set_format(0, right_border)

		format_borders(sheet1, row_count, {right_border_center: right_border_center, center: center})

		row_count +=1

		@tsm_sales_call_details.each do |key, reps|
			unless key == :all_calls
				@tsm_sales_call_details[key].each do |rep, value|
					unless rep == :Total
						sheet1.row(row_count).replace [rep.to_s, value[:Q1][:bus_plan], value[:Q1][:non_bus_plan], value[:Q1][:total], value[:Q2][:bus_plan], value[:Q2][:non_bus_plan], value[:Q2][:total], value[:Q3][:bus_plan], value[:Q3][:non_bus_plan], value[:Q3][:total], value[:Q4][:bus_plan], value[:Q4][:non_bus_plan], value[:Q4][:total], value[:YTD][:bus_plan], value[:YTD][:non_bus_plan], value[:YTD][:total]]
						
						format_bg_w_border(sheet1, row_count, {background: right_border})
						
						row_count += 1
					end
				end
				sheet1.row(row_count).replace ["#{key} - Team Totals", reps[:Total][:Q1][:bus_plan], reps[:Total][:Q1][:non_bus_plan], reps[:Total][:Q1][:total], reps[:Total][:Q2][:bus_plan], reps[:Total][:Q2][:non_bus_plan], reps[:Total][:Q2][:total],reps[:Total][:Q3][:bus_plan], reps[:Total][:Q3][:non_bus_plan], reps[:Total][:Q3][:total], reps[:Total][:Q4][:bus_plan], reps[:Total][:Q4][:non_bus_plan], reps[:Total][:Q4][:total], reps[:Total][:YTD][:bus_plan], reps[:Total][:YTD][:non_bus_plan], reps[:Total][:YTD][:total]]
				0.upto(15) do |num|
					sheet1.row(row_count).set_format(num,total_background)
				end
				
				format_bg_w_border(sheet1, row_count, {background: total_background_w_right_border})

				row_count += 1
			end
		end

		@tsm_sales_call_details.each do |key, reps|
			if key == :all_calls
				@tsm_sales_call_details[key].each do |rep, value|
					if rep == :all_calls
						sheet1.row(row_count).replace ["Total All", value[:Q1][:bus_plan], value[:Q1][:non_bus_plan], value[:Q1][:total], value[:Q2][:bus_plan], value[:Q2][:non_bus_plan], value[:Q2][:total], value[:Q3][:bus_plan], value[:Q3][:non_bus_plan], value[:Q3][:total], value[:Q4][:bus_plan], value[:Q4][:non_bus_plan], value[:Q4][:total], value[:YTD][:bus_plan], value[:YTD][:non_bus_plan], value[:YTD][:total]]
						0.upto(15) do |num|
							sheet1.row(row_count).set_format(num,table_background)
						end

						format_bg_w_border(sheet1, row_count, {background: table_background_w_right_border})
					end
				end
			end
		end

		row_count += 2
		sheet1.row(row_count).replace ["", "#{@Q1}", "", "","#{@Q2}", "", "", "#{@Q3}", "", "", "#{@Q4}", "", "", "Year to Date", "", ""]
		
		0.upto(15) do |num|
			sheet1.row(row_count).set_format(num, header_border)
		end

		merge_cells(sheet1, row_count)

		row_count += 1
		sheet1.row(row_count).replace ["", "Bus Plan", "Non BP", "Calls/Rep/wk", "Bus Plan", "Non BP", "Calls/Rep/wk", "Bus Plan", "Non BP", "Calls/Rep/wk", "Bus Plan", "Non BP", "Calls/Rep/wk", "Bus Plan", "Non BP", "Calls/Rep/wk"]
		
		sheet1.row(row_count).set_format(0, right_border)
		format_borders(sheet1, row_count, {right_border_center: right_border_center, center: center})
		
		row_count += 1
		
		@tsm_sales_call_perc_detail.each do |key, reps|
			unless key == :all_calls
				reps.each do |rep, value|
					unless rep == :Total
						sheet1.row(row_count).replace [rep.to_s, value[:Q1][:bus_plan], value[:Q1][:non_bus_plan], value[:Q1][:total], value[:Q2][:bus_plan], value[:Q2][:non_bus_plan], value[:Q2][:total], value[:Q3][:bus_plan], value[:Q3][:non_bus_plan], value[:Q3][:total], value[:Q4][:bus_plan], value[:Q4][:non_bus_plan], value[:Q4][:total], value[:YTD][:bus_plan], value[:YTD][:non_bus_plan], value[:YTD][:total]]
						sheet1.row(row_count).set_format(0, right_border)
						[1,2,4,5,7,8,10,11,13,14].each do |num|
							sheet1.row(row_count).set_format(num,background[set_background_color(sheet1[row_count, num], "perc")])
						end
						[3,6,9,12,15].each do |num|
							sheet1.row(row_count).set_format(num,background_border_right[set_background_color(sheet1[row_count, num])])
						end
						row_count += 1
					end
				end
				sheet1.row(row_count).replace ["#{key} - Team Totals", reps[:Total][:Q1][:bus_plan], reps[:Total][:Q1][:non_bus_plan], reps[:Total][:Q1][:total], reps[:Total][:Q2][:bus_plan], reps[:Total][:Q2][:non_bus_plan], reps[:Total][:Q2][:total],reps[:Total][:Q3][:bus_plan], reps[:Total][:Q3][:non_bus_plan], reps[:Total][:Q3][:total], reps[:Total][:Q4][:bus_plan], reps[:Total][:Q4][:non_bus_plan], reps[:Total][:Q4][:total], reps[:Total][:YTD][:bus_plan], reps[:Total][:YTD][:non_bus_plan], reps[:Total][:YTD][:total]]
				sheet1.row(row_count).set_format(0, total_background_w_right_border)
				[1,2,4,5,7,8,10,11,13,14].each do |num|
					sheet1.row(row_count).set_format(num,background[set_background_color(sheet1[row_count, num], "perc")])
				end
				[3,6,9,12,15].each do |num|
					sheet1.row(row_count).set_format(num,background_border_right[set_background_color(sheet1[row_count, num])])
				end
				row_count += 1
			end
		end

		sheet1.column(0).width = 25
		spreadsheet = StringIO.new
		book.write spreadsheet
		send_data spreadsheet.string, filename: 'salesforce.xls', type: "application/vnd.ms-excel"
	end

	def set_background_color(value, type="decimal")
		SalesForce.cell_color(value, type).to_sym
	end

	def merge_cells(sheet, row)
		sheet.merge_cells row, 1, row, 3
		sheet.merge_cells row, 4, row, 6
		sheet.merge_cells row, 7, row, 9
		sheet.merge_cells row, 10,row, 12
		sheet.merge_cells row, 13,row, 15
		sheet
	end

	def format_borders(sheet, row, *params)
		right_border_center = params.last[:right_border_center]
		center = params.last[:center]
		1.upto(2) do |num|
			sheet.row(row).set_format(num, center)
		end
		sheet.row(row).set_format(3, right_border_center)
		4.upto(5) do |num|
			sheet.row(row).set_format(num, center)
		end
		sheet.row(row).set_format(6, right_border_center)
		7.upto(8) do |num|
			sheet.row(row).set_format(num, center)
		end
		sheet.row(row).set_format(9, right_border_center)
		10.upto(11) do |num|
			sheet.row(row).set_format(num, center)
		end
		sheet.row(row).set_format(12, right_border_center)
		13.upto(14) do |num|
			sheet.row(row).set_format(num, center)
		end
		sheet.row(row).set_format(15, right_border_center)
		sheet
	end

	def format_bg_w_border(sheet, row, *params)
		row_format = params.last[:background]
		sheet.row(row).set_format(0, row_format)
		sheet.row(row).set_format(3, row_format)
		sheet.row(row).set_format(6, row_format)
		sheet.row(row).set_format(9, row_format)
		sheet.row(row).set_format(12,row_format)
		sheet.row(row).set_format(15,row_format)
		sheet
	end
end