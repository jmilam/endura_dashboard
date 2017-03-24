class Sros::OrderEntriesController < ApplicationController
	def index
	  @title = "SRO OE Dashboard"
	  #Initial Values set for variables
	  @sro_overview = Hash.new
	  @sro_by_customer = Hash.new
	  @current_year = Date.today.year
	  @previous_year = Date.today.last_year.year
	  @performance_data = {orders: Array.new, lines: Array.new}
	  @overview_data = Array.new
	  @user_names = ['User Name']
	  @auto_orders = ['Auto Orders']
	  @manual_orders = ['Manual Orders']
	  @auto_lines = ['Auto Lines']
	  @manual_lines = ['Manual Lines']
	  @user_exceptions = ['djorgens', 'mdavis', 'hmeitl', 'hbenson', 'mdraughn', 'root', 'awatson', 'tbell']

	  @start_date = params[:start_date].blank? ? (Date.today.beginning_of_week).strftime("%D") : params[:start_date]
	  @end_date = params[:end_date].blank? ? (Date.today.end_of_week).strftime("%D") : params[:end_date]
    @total_edi_orders = 0
	  @total_manual_orders = 0
	  @total_man_lag = 0
	  @total_edi_lag = 0
	  @total_scn_lag = 0
	  @total_scn_orders = 0
	  @total_edi_lines = 0
	  @total_manual_lines = 0
	  @total_scn_lines = 0
	  @total_scn_sros = 0
	  @total_edi_sros = 0
	  @total_manual_sros = 0
	  @total_customers = 0
	  @total_man_dollar = 0
		@total_edi_dollar = 0
		@total_scn_dollar = 0
		@total_sro_prev_ytd = 0
		@total_sro_curr_ytd = 0

	  #URI call to QAD API to receive JSON data
	  uri = URI(self.api_url + "/sro/order_entry?start=#{@start_date}&end=#{@end_date}&dept=ORD")

	  response = Net::HTTP.get(uri)

	  json_response =  JSON.parse(response)
	  @user_stats = json_response["userstats"]
	  @sro_summary = json_response["sros"]
	  @sro_prev = json_response["srosPrevYtd"]
	  @sro_type_by_month = json_response["srotype"]
	  @user_unconfirmed = json_response["unconfirmed"]
	  @sro_curr_ytd = json_response["srosCurrYtd"]
	  @user_unconfirmed = Sro.group_unconfirmed(json_response["unconfirmed"], @user_exceptions)
	  @user_unconfirmed_chart_data = @user_unconfirmed[1]
	  @user_unconfirmed = @user_unconfirmed[0]
	  @unconfirmed_detail = json_response["unconfdetail"].sort_by {|data| [data["ttdetuserid"], data["ttdetdate"]]}
	  @unconfirmed_det_chart = Sro.group_unconfirmed_status(@unconfirmed_detail)
	  @value_status = false
	  @unconfirmed_det_chart.each {|key, value| @value_status = true if value.to_f > 0}
    
    #This cycles the returned JSON data from QAD and builds an Array for Google Chart Visualization for the Summary Data
	  @sro_summary.each do |summary|
	  	unless @user_exceptions.include?(summary["sro-taken"].downcase)
		    if @current_year == summary["sro-ent-date"].to_date.year
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
						if summary["sro-ent-date"].to_date.month == Date.today.month
						  @sro_overview[summary["sro-taken"]] = {summary["sro-type"] => {"current_ytd" => summary["sro-line-total"], "current_month" => summary["sro-line-total"]}}
						else
						  @sro_overview[summary["sro-taken"]] = {summary["sro-type"] => {"current_ytd" => summary["sro-line-total"]}}
						end
		      end
		    end
	    end
	  end

	  @sro_curr_ytd.each do |summary|
	  	if @sro_by_customer.keys.include?(summary["sro-name"])
        @sro_by_customer[summary["sro-name"]] = Sro.calculate_customer_ytd(@sro_by_customer[summary["sro-name"]], summary["sro-line-total"], summary["sro-ent-date"])
      else
        @sro_by_customer[summary["sro-name"]] = summary["sro-line-total"]
      end unless summary["sro-name"].empty?
      @total_sro_curr_ytd += summary["sro-line-total"]
	  end

	  @sro_prev.each do |summary|
      if @sro_overview.key?(summary["sro-taken"])
      	@sro_overview[summary["sro-taken"]].key?(summary["sro-type"]) ? @sro_overview[summary["sro-taken"]][summary["sro-type"]]["previous_year"].nil? ? @sro_overview[summary["sro-taken"]][summary["sro-type"]]["previous_year"] = summary["sro-line-total"] : @sro_overview[summary["sro-taken"]][summary["sro-type"]]["previous_year"] += summary["sro-line-total"] : next
      end
      @total_sro_prev_ytd += summary["sro-line-total"]
	  end
	  @sro_by_customer = @sro_by_customer.sort_by {|key, value| value }.reverse[0..19].to_h

	  #This cycles the returned JSON data from QAD and builds an Array for Google Chart Visualization for the Performance Snapshot
	  @sro_month = @user_stats.first["t_month"].to_date.strftime("%b '%y")
    @total_orders = @user_stats.inject(1.0){|sum, hash| sum + (hash["t_edi_ord"] + hash["t_scn_ord"] + hash["t_man_ord"])}
    @total_lines = @user_stats.inject(1.0){|sum, hash| sum + (hash["t_edi_line"] + hash["t_scn_line"] + hash["t_man_line"])}

    # This builds calculations for the snapshot chart
	  @user_stats.each do |stats|
	  	unless @user_exceptions.include?(stats["t_userid"].downcase)
		    @auto_orders << (stats["t_edi_ord"] + stats["t_scn_ord"])
	      @manual_orders <<  stats["t_man_ord"]
		    @auto_lines << (stats["t_edi_line"] + stats["t_scn_line"])
		    @manual_lines << stats["t_man_line"]
		    @user_names << stats["t_userid"]
		    stats["order_percent"] = (((stats["t_edi_ord"] + stats["t_scn_ord"] + stats["t_man_ord"]) / @total_orders) * 100).round.to_s + "%"
		    stats["line_percent"] = (((stats["t_edi_line"] + stats["t_scn_line"] + stats["t_man_line"]) /@total_lines) * 100).round.to_s + "%"	    

	      @total_manual_orders += stats["t_man_ord"]
		    @total_edi_orders += stats["t_edi_ord"]
		    @total_scn_orders += stats["t_scn_ord"]
		    @total_edi_lines += stats["t_edi_line"]
		    @total_scn_lines += stats["t_scn_line"]
		    @total_manual_lines += (stats["t_man_line"])
		    @total_edi_sros += stats["t_edi_sro"]
		    @total_scn_sros += stats["t_scn_sro"]
	 	    @total_manual_sros += stats["t_man_sro"]
	 	    @total_customers += stats["t_custcount"]
	 	    @total_man_lag += stats["t_man_lag"]
	 	    @total_scn_lag += stats["t_scn_lag"]
	 	    @total_edi_lag += stats["t_edi_lag"]
	 	    @total_man_dollar += stats["t_man_dol"]
	 	    @total_edi_dollar += stats["t_edi_dol"]
	 	    @total_scn_dollar += stats["t_scn_dol"]
	 	  end
	  end
    @user_stats << {"t_userid":"Total","t_man_dol": @total_man_dollar, "t_edi_dol": @total_edi_dollar, "t_scn_dol": @total_scn_dollar, "t_edi_sro": @total_edi_sros, "t_scn_sro": @total_scn_sros, "t_man_lag": @total_man_lag, "t_scn_lag": @total_scn_lag, "t_edi_lag": @total_edi_lag, "t_man_sro": @total_manual_sros,"t_edi_ord": @total_edi_orders, "t_scn_ord":@total_scn_orders, "t_man_ord":@total_manual_orders, "t_edi_line":@total_edi_lines, "t_scn_line":@total_scn_lines, "t_man_line":@total_manual_lines, "order_percent":"100%", "line_percent":"100%", "t_cust": @total_customers, "export": false}.stringify_keys	  

    @performance_data[:orders] << @user_names
    @performance_data[:lines] << @user_names
	  @performance_data[:orders] << @auto_orders
	  @performance_data[:orders] << @manual_orders
	  @performance_data[:lines] << @auto_lines
	  @performance_data[:lines] << @manual_lines

	  @sro_chart_data = Hash.new
	  @year_overview = [["Month", "CR", "DF", "RT"]]
	  @sro_type_by_month.each do |sro_by_mth|
	    if @sro_chart_data.has_key?(sro_by_mth["ttmonth"].to_date.strftime("%b '%y"))
	      @sro_chart_data[sro_by_mth["ttmonth"].to_date.strftime("%b '%y")] << [sro_by_mth["tttype"],  sro_by_mth["ttamt"]]
	    else
 	      #Move to next array of data
	      @sro_chart_data[sro_by_mth["ttmonth"].to_date.strftime("%b '%y")] = [[sro_by_mth["tttype"], sro_by_mth["ttamt"]]]
	    end
	  end
	  @sro_chart_data.each do |key, value|
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
