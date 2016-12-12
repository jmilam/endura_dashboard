class Sros::AllsController < ApplicationController
  def index
    @sro_by_division = Hash.new
    @sro_by_type = Hash.new
    @sro_by_prod_line = Hash.new
    @sro_by_dept = Hash.new
    @start_date = (Date.today.beginning_of_week - 1.week).strftime("%D")
    @end_date = (Date.today.end_of_week - 1.week).strftime("%D")
    
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
        if @sro_by_type[sros["sro-div"]][sros["sro-type"]].nil?
          @sro_by_type[sros["sro-div"]] = {sros["sro-type"] => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
	else
	  @sro_by_type[sros["sro-div"]][sros["sro-type"]] = Sro.calculate_all_sros(@sro_by_type[sros["sro-div"]][sros["sro-type"]], sros)
	end
      else
    	#@sro_by_type["sro-div"] = Sro.create_new_sro_data(sros["sro-div"], sros["sro-type"], @sro_by_type)
        @sro_by_type[sros["sro-div"]] = {sros["sro-type"] => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
        @sro_by_type[sros["sro-div"]][sros["sro-type"]] = Sro.calculate_all_sros(@sro_by_type[sros["sro-div"]][sros["sro-type"]],sros)
      end

      if @sro_by_prod_line.keys.include?(sros["sro-div"])
	if @sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]].nil?
          @sro_by_prod_line[sros["sro-div"]] = {sros["sro-prodline"] => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
	else
          @sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]] = Sro.calculate_all_sros(@sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]], sros)
	end
      else
        @sro_by_prod_line[sros["sro-div"]] = {sros["sro-prodline"] => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
        @sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]] = Sro.calculate_all_sros(@sro_by_prod_line[sros["sro-div"]][sros["sro-prodline"]],sros)
      end

      if @sro_by_dept.keys.include?(sros["sro-div"])
 	if @sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]].nil?
          @sro_by_dept[sros["sro-div"]] = {sros["xxsro-so-dept"] => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
        else
	  @sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]] = Sro.calculate_all_sros(@sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]], sros)
	end
      else
        @sro_by_dept[sros["sro-div"]] = {sros["xxsro-so-dept"] => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
	@sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]] = Sro.calculate_all_sros(@sro_by_dept[sros["sro-div"]][sros["xxsro-so-dept"]],sros)
      end
    end
  end
end
