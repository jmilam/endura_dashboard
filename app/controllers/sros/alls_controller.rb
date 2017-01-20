class Sros::AllsController < ApplicationController
  def index
    @sro_by_division = Hash.new
    @sro_by_type = Hash.new
    @sro_by_prod_line = Hash.new
    @sro_by_dept = Hash.new
    @sro_by_customer = Hash.new
    @sro_by_responsibility = Hash.new
    @sro_by_customer = Hash.new
    
    @start_date = params[:start_date].blank? ? (Date.today.beginning_of_week - 1.week).strftime("%D"): params[:start_date]
    @end_date = params[:end_date].blank? ? (Date.today.end_of_week - 1.week).strftime("%D") : params[:end_date]
    @sro_start = params[:start_date].blank? ? (Date.today.beginning_of_month).strftime("%D"): params[:start_date]
    @sro_end = params[:end_date].blank? ? (Date.today.end_of_month).strftime("%D") : params[:end_date]
    @criteria = ReportCriteria.all

    #Pulls data from Mysql Table and builds created responsibilities
    Responsibility.all.each do |responsibility|
      @sro_by_failure = Hash.new
      responsibility.failure_codes.each {|code| @sro_by_failure["#{code.name}"] = Array.new}
      @sro_by_responsibility["#{responsibility.name}"] = @sro_by_failure
    end

    #Pulls Data from QAD through API call.
    uri = URI(self.api_url + "xxapioesrodashboard.p?start=#{@start_date}&end=#{@end_date}&srodetailfrom=#{@sro_start}&srodetailto=#{@sro_end}")
    response = Net::HTTP.get(uri)

    #Cycles through returned data and builds Hash of totals to display
    JSON.parse(response)["sros"].each do |sros|
      #Builds data based on Responsibility Specifications
      if @sro_by_responsibility.values[0].keys.include?(sros["sro-failure1"])
        if @sro_by_responsibility.values[0][sros["sro-failure1"]].empty?
          @sro_by_responsibility.values[0][sros["sro-failure1"]] = Sro.create_by_responsibility(sros["sro-desc"])
        else
          #Add Totals
          @sro_by_responsibility.values[0] = Sro.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], @sro_by_responsibility.values[0], sros["sro-line-total"])
        end
      elsif @sro_by_responsibility.values[1].keys.include?(sros["sro-failure1"])
        if @sro_by_responsibility.values[1][sros["sro-failure1"]].empty?
          @sro_by_responsibility.values[1][sros["sro-failure1"]] = Sro.create_by_responsibility(sros["sro-desc"])
        else
          @sro_by_responsibility.values[1] = Sro.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], @sro_by_responsibility.values[1], sros["sro-line-total"])
        end
      elsif @sro_by_responsibility.values[2].keys.include?(sros["sro-failure1"])
        if @sro_by_responsibility.values[2][sros["sro-failure1"]].empty?
          @sro_by_responsibility.values[2][sros["sro-failure1"]] = Sro.create_by_responsibility(sros["sro-desc"])
        else
          @sro_by_responsibility.values[2] = Sro.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], @sro_by_responsibility.values[2], sros["sro-line-total"])
        end
      elsif @sro_by_responsibility.values[3].keys.include?(sros["sro-failure1"])
        if @sro_by_responsibility.values[3][sros["sro-failure1"]].empty?
          @sro_by_responsibility.values[3][sros["sro-failure1"]] = Sro.create_by_responsibility(sros["sro-desc"])
        else
          @sro_by_responsibility.values[3] = Sro.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], @sro_by_responsibility.values[3], sros["sro-line-total"])
        end
      elsif @sro_by_responsibility.values[4].keys.include?(sros["sro-failure1"])
        if @sro_by_responsibility.values[4][sros["sro-failure1"]].empty?
          @sro_by_responsibility.values[4][sros["sro-failure1"]] = Sro.create_by_responsibility(sros["sro-desc"])
        else
          @sro_by_responsibility.values[4] = Sro.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], @sro_by_responsibility.values[4], sros["sro-line-total"])
        end
      end

      #Builds data based on Customer Specifications

      #
      if @sro_by_division.keys.include?(sros["sro-div"])
        @sro_by_division[sros["sro-div"]] = Sro.calculate_all_sros(@sro_by_division[sros["sro-div"]], sros)
      else
        unless sros["sro-div"].empty?
          @sro_by_division[sros["sro-div"]] = Sro.create_sro_with_hash(@sro_by_division, sros["sro-div"], nil, sros)
        end
      end

      #
      if @sro_by_type.keys.include?(sros["sro-div"])
        if @sro_by_type[sros["sro-div"]].keys.include?(sros["sro-type"])
          @sro_by_type[sros["sro-div"]][sros["sro-type"]] = Sro.calculate_all_sros(@sro_by_type[sros["sro-div"]][sros["sro-type"]], sros)
      	else
      	  @sro_by_type[sros["sro-div"]][sros["sro-type"]] = {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}
      	end
      else
        @sro_by_type[sros["sro-div"]] = {sros["sro-type"] => Sro.create_sro_with_hash(@sro_by_type, sros["sro-div"], sros["sro-type"], sros)}
      end unless sros["sro-div"].empty?

      #
      if @sro_by_prod_line.keys.include?(sros["sro-div"])
      	if @sro_by_prod_line[sros["sro-div"]].keys.include?(sros["sro-prodline"])
      	  @sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]] = Sro.calculate_all_sros(@sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]], sros)
      	else
      	  @sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]] = {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}	
      	end
      else
        @sro_by_prod_line[sros["sro-div"]] = {sros["sro-prodline"] => Sro.create_sro_with_hash(@sro_by_prod_line, sros["sro-div"], sros["sro-prodline"], sros)}
      end unless sros["sro-div"].empty?

      #
      if @sro_by_dept.keys.include?(sros["sro-div"])
       	if @sro_by_dept[sros["sro-div"]].keys.include?(sros["xxsro-so-dept"])
      	  @sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]] = Sro.calculate_all_sros(@sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]], sros)
        else
          @sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]] = {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}
        end
      else
        @sro_by_dept[sros["sro-div"]] = {sros["xxsro-so-dept"] => Sro.create_sro_with_hash(@sro_by_prod_line, sros["sro-div"], sros["xxsro-so-dept"], sros)}
      end unless sros["sro-div"].empty?

      #
      # if @sro_by_customer.keys.include?(sros["sro-name"])
      #   p @sro_by_customer[sros["sro-name"]]
      #   @sro_by_customer[sros["sro-name"]] = Sro.calculate_customer_ytd(@sro_by_customer[sros["sro-name"]],@sro_by_customer[sros["sro-name"]][sros["srod-site"]], sros["sro-line-total"], sros["sro-ent-date"], sros["srod-site"])
      # else
      #   @sro_by_customer[sros["sro-name"]] = {sros["srod-site"] => sros["sro-line-total"]}
      # end unless sros["sro-name"].empty?
    end

    @sro_by_responsibility.values[0] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[0])
    @sro_by_responsibility.values[1] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[1])
    @sro_by_responsibility.values[2] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[2])
    @sro_by_responsibility.values[3] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[3])
    @sro_by_responsibility.values[4] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[4])
    @sro_by_responsibility["Grand Total"] = {"Grand Total" => Sro.totals_by_site}

    #Sorts built data
    @sro_by_division = @sro_by_division.sort_by {|key, value| key}.to_h
    @sro_by_type = Sro.sort_data(@sro_by_type).sort.to_h
    @sro_by_prod_line = Sro.sort_data(@sro_by_prod_line).sort.to_h
    @sro_by_dept = Sro.sort_data(@sro_by_dept).sort.to_h
  end
end


