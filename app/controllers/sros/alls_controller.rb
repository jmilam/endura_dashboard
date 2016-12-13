class Sros::AllsController < ApplicationController
  def index
    @sro_by_division = Hash.new
    @sro_by_type = Hash.new
    @sro_by_prod_line = Hash.new
    @sro_by_dept = Hash.new
    @sro_by_customer = Hash.new
    @start_date = params[:start_date].blank? ? (Date.today.beginning_of_week - 1.week).strftime("%D"): params[:start_date]
    @end_date = params[:end_date].blank? ? (Date.today.end_of_week - 1.week).strftime("%D") : params[:end_date]
    
    uri = URI(self.api_url + "xxapioesrodashboard.p?start=#{@start_date}&end=#{@end_date}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)["sros"].each do |sros|
      if @sro_by_division.keys.include?(sros["sro-div"])
        @sro_by_division[sros["sro-div"]] = Sro.calculate_all_sros(@sro_by_division[sros["sro-div"]], sros)
      else
        unless sros["sro-div"].empty?
          @sro_by_division[sros["sro-div"]] = {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}
          @sro_by_division[sros["sro-div"]] = Sro.calculate_all_sros(@sro_by_division[sros["sro-div"]], sros)      
        end
      end

      if @sro_by_type.keys.include?(sros["sro-div"])
        if @sro_by_type[sros["sro-div"]].keys.include?(sros["sro-type"])
          @sro_by_type[sros["sro-div"]][sros["sro-type"]] = Sro.calculate_all_sros(@sro_by_type[sros["sro-div"]][sros["sro-type"]], sros)
	else
	  @sro_by_type[sros["sro-div"]][sros["sro-type"]] = {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}
	end
      else
	@sro_by_type[sros["sro-div"]] = {sros["sro-type"] => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
        @sro_by_type[sros["sro-div"]][sros["sro-type"]] = Sro.calculate_all_sros(@sro_by_type[sros["sro-div"]][sros["sro-type"]],sros)
      end unless sros["sro-div"].empty?

      if @sro_by_prod_line.keys.include?(sros["sro-div"])
	if @sro_by_prod_line[sros["sro-div"]].keys.include?(sros["sro-prodline"])
	  @sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]] = Sro.calculate_all_sros(@sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]], sros)
	else
	  @sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]] = {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}	
	end
      else
        @sro_by_prod_line[sros["sro-div"]] = {sros["sro-prodline"] => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
        @sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]] = Sro.calculate_all_sros(@sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]],sros)
      end unless sros["sro-div"].empty?

      if @sro_by_dept.keys.include?(sros["sro-div"])
 	if @sro_by_dept[sros["sro-div"]].keys.include?(sros["xxsro-so-dept"])
	  @sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]] = Sro.calculate_all_sros(@sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]], sros)
        else
          @sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]] = {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}
	end
      else
        @sro_by_dept[sros["sro-div"]] = {sros["xxsro-so-dept"] => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
	@sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]] = Sro.calculate_all_sros(@sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]],sros)
      end unless sros["sro-div"].empty?

      if @sro_by_customer.keys.include?(sros["sro-name"])
        @sro_by_customer[sros["sro-name"]] = Sro.calculate_customer_ytd(@sro_by_customer[sros["sro-name"]], sros["sro-line-total"], sros["sro-ent-date"])
      else
	@sro_by_customer[sros["sro-name"]] = sros["sro-line-total"]
      end unless sros["sro-name"].empty?
    end
    @sro_by_division = @sro_by_division.sort_by {|key, value| key}.to_h
    @sro_by_type = Sro.sort_data(@sro_by_type).sort.to_h
    @sro_by_prod_line = Sro.sort_data(@sro_by_prod_line).sort.to_h
    @sro_by_dept = Sro.sort_data(@sro_by_dept).sort.to_h
    @sro_by_customer = @sro_by_customer.sort_by {|key, value| value }.reverse[0..19].to_h
  end
end


