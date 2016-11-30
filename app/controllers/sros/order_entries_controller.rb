class Sros::OrderEntriesController < ApplicationController
	def index
	  #Initial Values set for variables
	  @current_yr_summary = Hash.new
	  @previous_yr_summary = Hash.new
	  @current_year = Date.today.year
	  @previous_year = Date.today.last_year.year
	  @current_year_total = 0
          @previous_year_total = 0
	  @performance_data = Array.new
	  @user_names = ['Order Type']
	  @auto_orders = ['Auto Orders']
	  @manual_orders = ['Manual Orders']
	  @auto_lines = ['Auto Lines']
	  @manual_lines = ['Manual Lines']
	
	  #URI call to QAD API to receive JSON data
	  uri = URI("http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/xxapioesrodashboard.p?start=#{params[:start_date]}&end=#{params[:end_date]}")
	  response = Net::HTTP.get(uri)
	  json_response =  JSON.parse(response)
	  @user_stats = json_response["userstats"]
	  @sro_summary = json_response["sros"]

          #This cycles the returned JSON data from QAD and builds an Array for Google Chart Visualization for the Summary Data
	  @sro_summary.each do |summary|
	    if @current_year == summary["sro-due-date"].to_date.year
	      if @current_yr_summary.key?(summary["sro-taken"])
                @current_yr_summary[summary["sro-taken"]].key?(summary["sro-type"]) ? @current_yr_summary[summary["sro-taken"]][summary["sro-type"]] += summary["sro-line-total"] : @current_yr_summary[summary["sro-taken"]] = {summary["sro-type"] => summary["sro-line-total"]}
	        #@current_yr_summary[summary["sro-taken"]]["total"] += summary["sro-line-total"]
	      else
	        @current_yr_summary[summary["sro-taken"]] = summary["sro-taken"]
	        @current_yr_summary[summary["sro-taken"]] = {summary["sro-type"] => summary["sro-line-total"]}
		
	      end
	      #Add calculations to current Year totals
	      @current_year_total += summary["sro-line-total"]
	    else 
	      if @previous_yr_summary.key?(summary["sro-taken"])
                @previous_yr_summary[summary["sro-taken"]].key?(summary["sro-type"]) ? @previous_yr_summary[summary["sro-taken"]][summary["sro-type"]] += summary["sro-line-total"] : @previous_yr_summary[summary["sro-taken"]] = {summary["sro-type"] => summary["sro-line-total"]}
                #@previous_yr_summary[summary["sro-taken"]]["total"] += summary["sro-line-total"]
              else
                @previous_yr_summary[summary["sro-taken"]] = summary["sro-taken"]
                @previous_yr_summary[summary["sro-taken"]] = {summary["sro-type"] => summary["sro-line-total"]}
              end

	      #Add calculations to previous Year totals
	      @previous_year_total += summary["sro-line-total"]
            end
	  end
	  
	  #This cycles the returned JSON data from QAD and builds an Array for Google Chart Visualization for the Performance Snapshot
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
	end
end
