class Sros::OrderEntriesController < ApplicationController
	def index
	  @title = "SRO OE Dashboard"
	  #Initial Values set for variables
	  @sro_overview = Hash.new
	  @current_year = Date.today.year
	  @previous_year = Date.today.last_year.year
	  @performance_data = Array.new
	  @overview_data = Array.new
	  @user_names = ['User Name']
	  @auto_orders = ['Auto Orders']
	  @manual_orders = ['Manual Orders']
	  @auto_lines = ['Auto Lines']
	  @manual_lines = ['Manual Lines']
	  @start_date = (Date.today.beginning_of_week - 1.week).strftime("%D")
	  @end_date = (Date.today.end_of_week - 1.week).strftime("%D")

	  #URI call to QAD API to receive JSON data
	  uri = URI("http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/xxapioesrodashboard.p?start=#{@start_date}&end=#{@end_date}")
	  response = Net::HTTP.get(uri)
	  json_response =  JSON.parse(response)
	  @user_stats = json_response["userstats"]
	  @sro_summary = json_response["sros"]
	  @sro_type_by_month = json_response["srotype"]

          #This cycles the returned JSON data from QAD and builds an Array for Google Chart Visualization for the Summary Data
	  @sro_summary.each do |summary|
	    if @current_year == summary["sro-due-date"].to_date.year
	      if @sro_overview.key?(summary["sro-taken"])
		if @sro_overview[summary["sro-taken"]].key?(summary["sro-type"]) 
		  if @sro_overview[summary["sro-taken"]][summary["sro-type"]]["current_ytd"].nil?
		    @sro_overview[summary["sro-taken"]][summary["sro-type"]]["current_ytd"] = summary["sro-line-total"]
		  else 
		    @sro_overview[summary["sro-taken"]][summary["sro-type"]]["current_ytd"] += summary["sro-line-total"]
		  end
		else
		  @sro_overview[summary["sro-taken"]][summary["sro-type"]] =  {"current_ytd" => summary["sro-line-total"]}
	        end
	      else
		@sro_overview[summary["sro-taken"]] = summary["sro-taken"]
		if summary["sro-due-date"].to_date.month == Date.today.month
		  @sro_overview[summary["sro-taken"]] = {summary["sro-type"] => {"current_ytd" => summary["sro-line-total"], "current_month" => summary["sro-line-total"]}}
		else
		  @sro_overview[summary["sro-taken"]] = {summary["sro-type"] => {"current_ytd" => summary["sro-line-total"]}}
		end
	      end
	    else
	      if @sro_overview.key?(summary["sro-taken"]) 
		@sro_overview[summary["sro-taken"]].key?(summary["sro-type"]) ? @sro_overview[summary["sro-taken"]][summary["sro-type"]]["previous_year"].nil? ? @sro_overview[summary["sro-taken"]][summary["sro-type"]]["previous_year"] = summary["sro-line-total"] : @sro_overview[summary["sro-taken"]][summary["sro-type"]]["previous_year"] += summary["sro-line-total"] : @sro_overview[summary["sro-taken"]] = {summary["sro-type"] => {"previous_year" => summary["sro-line-total"]}} 
              else
		@sro_overview[summary["sro-taken"]] = summary["sro-taken"]
		@sro_overview[summary["sro-taken"]] = {summary["sro-type"] => {"previous_year" => summary["sro-line-total"]}}
              end
            end
	  end
	  
	  #This cycles the returned JSON data from QAD and builds an Array for Google Chart Visualization for the Performance Snapshot
	  @sro_month = @user_stats.first["t_month"].to_date.strftime("%b '%y")
	  @user_stats.each do |stats|
	    @user_names << stats["t_userid"]
	    @auto_orders << (stats["t_edi_ord"] + stats["t_scn_ord"])
            @manual_orders << stats["t_man_ord"]
	    @auto_lines << (stats["t_edi_line"] + stats["t_scn_line"])
	    @manual_lines << stats["t_man_line"]
	  end
	  
	  @performance_data << @user_names
	  @performance_data << @auto_orders
	  @performance_data << @manual_orders
	  @performance_data << @auto_lines
	  @performance_data << @manual_lines

	  @sro_overview = Hash.new
	  @year_overview = [["Month", "CR", "DF", "RT"]]
	  @sro_type_by_month.each do |sro_by_mth|
	    if @sro_overview.has_key?(sro_by_mth["ttmonth"])
	      @sro_overview[sro_by_mth["ttmonth"]] << [sro_by_mth["tttype"],  sro_by_mth["ttamt"]]
	    else
 	      #Move to next array of data
	      @sro_overview[sro_by_mth["ttmonth"]] = [[sro_by_mth["tttype"], sro_by_mth["ttamt"]]]
	    end
	  end
	  @sro_overview.each do |key, value|
	    working_array = [key]

	    value.each do |v|
	      case v[0]
	      when "CR"
	        working_array[1] = v[1]
	      when "DF"
		working_array[2] = v[1]
	      when "RT"
		working_array[3] = v[1]
	      end
	    end
	    @year_overview << working_array
	  end
	end
end
