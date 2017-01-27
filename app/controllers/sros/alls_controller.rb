class Sros::AllsController < ApplicationController
  def index
    @sro_by_responsibility = Hash.new
    @sro_by_customer = Hash.new
    @sro_by_site_customer = {"1000" => {"Total" => {failure_code: "", total: 0.00}}, "2000" => {"Total" => {failure_code: "", total: 0.00}}, "3000" => {"Total" => {failure_code: "", total: 0.00}}, "4300" => {"Total" => {failure_code: "", total: 0.00}}, "5000" => {"Total" => {failure_code: "", total: 0.00}}, "9000" => {"Total" => {failure_code: "", total: 0.00}}, "Total" => {"Total" => {failure_code: "", total: 0.00}}}
    @sro_by_site_reason= {"1000" => {"Total" => {failure_code: "", total: 0.00}}, "2000" => {"Total" => {failure_code: "", total: 0.00}}, "3000" => {"Total" => {failure_code: "", total: 0.00}}, "4300" => {"Total" => {failure_code: "", total: 0.00}}, "5000" => {"Total" => {failure_code: "", total: 0.00}}, "9000" => {"Total" => {failure_code: "", total: 0.00}}, "Total" => {"Total" => {failure_code: "", total: 0.00}}}
    @sro_by_site_item = {"1000" => {"Total" => {failure_code: "", total: 0.00}}, "2000" => {"Total" => {failure_code: "", total: 0.00}}, "3000" => {"Total" => {failure_code: "", total: 0.00}}, "4300" => {"Total" => {failure_code: "", total: 0.00}}, "5000" => {"Total" => {failure_code: "", total: 0.00}}, "9000" => {"Total" => {failure_code: "", total: 0.00}}, "Total" => {"Total" => {failure_code: "", total: 0.00}}}
    
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
      @sro_by_responsibility = Sro.build_by_responsibility(sros, @sro_by_responsibility)
      @sro_by_customer = Sro.build_by_customer(sros, @sro_by_customer)
      @sro_by_site_customer = Sro.build_by_site_customer(sros, @sro_by_site_customer)
      @sro_by_site_reason = Sro.build_by_site_reason(sros, @sro_by_site_reason)
      @sro_by_site_item = Sro.build_by_site_item(sros, @sro_by_site_item)
    end

    @sro_by_responsibility.values[0] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[0])
    @sro_by_responsibility.values[1] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[1])
    @sro_by_responsibility.values[2] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[2])
    @sro_by_responsibility.values[3] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[3])
    @sro_by_responsibility.values[4] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[4])
    @sro_by_responsibility["Grand Total"] = {"Grand Total" => Sro.totals_by_site}
  end
end


