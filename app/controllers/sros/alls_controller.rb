class Sros::AllsController < ApplicationController
  require 'net/http'
  layout "email", except: [:index]
  def index
    @sro_by_responsibility = Hash.new
    @sro_by_customer = Hash.new
    @sro_by_site_customer_pie = Hash.new
    @sro_by_site_reason_pie = Hash.new
    @sro_by_site_item_pie = Hash.new
    @sro_by_site_customer = {"2000" => {"Total" => {failure_code: "", total: 0.00}}, "3000" => {"Total" => {failure_code: "", total: 0.00}}, "4300" => {"Total" => {failure_code: "", total: 0.00}}, "5000" => {"Total" => {failure_code: "", total: 0.00}}, "9000" => {"Total" => {failure_code: "", total: 0.00}}, "Total" => {"Total" => {failure_code: "", total: 0.00}}}
    @sro_by_site_reason= {"2000" => {"Total" => {failure_code: "", total: 0.00}}, "3000" => {"Total" => {failure_code: "", total: 0.00}}, "4300" => {"Total" => {failure_code: "", total: 0.00}}, "5000" => {"Total" => {failure_code: "", total: 0.00}}, "9000" => {"Total" => {failure_code: "", total: 0.00}}, "Total" => {"Total" => {failure_code: "", total: 0.00}}}
    @sro_by_site_item = {"2000" => {"Total" => {failure_code: "", total: 0.00}}, "3000" => {"Total" => {failure_code: "", total: 0.00}}, "4300" => {"Total" => {failure_code: "", total: 0.00}}, "5000" => {"Total" => {failure_code: "", total: 0.00}}, "9000" => {"Total" => {failure_code: "", total: 0.00}}, "Total" => {"Total" => {failure_code: "", total: 0.00}}}
    @sro_by_failure_code = {"Total" => {reason: "", "2000" => 0, "3000" => 0, "4300" => 0, "5000" => 0, "9000" => 0, "Total" => 0}}
    @start_date = params[:start_date].blank? ? (Date.today.beginning_of_week - 1.week).strftime("%D"): params[:start_date]
    @end_date = params[:end_date].blank? ? (Date.today.end_of_week - 1.week).strftime("%D") : params[:end_date]

    @criteria = ReportCriteria.all

    #Pulls data from Mysql Table and builds created responsibilities
    Responsibility.all.each do |responsibility|
      @sro_by_failure = Hash.new
      responsibility.failure_codes.each {|code| @sro_by_failure["#{code.name}"] = Array.new}
      @sro_by_responsibility["#{responsibility.name}"] = @sro_by_failure
    end

    #Pulls Data from QAD through API call.
    uri = URI(self.api_url + "/sro/order_entry?start=#{@start_date}&end=#{@end_date}&dept=All")
    response = Net::HTTP.get(uri)
    @sros = JSON.parse(response)["sros"]
    #Cycles through returned data and builds Hash of totals to display
    @sros.each do |sros|
      #Builds data based on Responsibility Specifications
      @sro_by_responsibility = Sro.build_by_responsibility(sros, @sro_by_responsibility)
      @sro_by_customer = Sro.build_by_customer(sros, @sro_by_customer)
      @sro_by_site_customer = Sro.build_by_site_customer(sros, @sro_by_site_customer)
      @sro_by_site_reason = Sro.build_by_site_reason(sros, @sro_by_site_reason)
      @sro_by_site_item = Sro.build_by_site_item(sros, @sro_by_site_item)
      @sro_by_failure_code = Sro.build_by_failure_code(sros, @sro_by_failure_code)
    end

    @sro_by_responsibility.values[0] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[0])
    @sro_by_responsibility.values[1] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[1])
    @sro_by_responsibility.values[2] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[2])
    @sro_by_responsibility.values[3] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[3])
    @sro_by_responsibility.values[4] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[4])
    @sro_by_responsibility["Grand Total"] = {"Grand Total" => Sro.totals_by_site}

    @sro_responsibiilty_pie = Sro.sort_for_legend(Sro.build_data_for_google_pies(@sro_by_responsibility, "responsibility"))
    @sro_responsibility_sites_pie = Sro.sort_for_legend(Sro.build_data_for_google_pies(@sro_by_responsibility, "responsibility", "by_grand_total"))

    @sro_by_customer["Grand Total"] = Sro.totals_by_site
    @sro_by_customer_pie = Sro.sort_for_legend(Sro.build_data_for_google_pies(@sro_by_customer, "customer"))
    @sro_by_customer_sites_pie = Sro.sort_for_legend(Sro.build_data_for_google_pies(@sro_by_customer, "customer", "by_grand_total"))
    @sro_by_customer = @sro_by_customer.sort_by {|key, value| key}
    @sro_by_customer.each_with_index {|data, index| @customer_grand_total_idx =  index unless data.find_index("Grand Total").nil?}


    @sro_by_site_customer.each do |site, data| 
      @sro_by_site_customer_pie[site] = Sro.sort_for_legend(Sro.build_data_for_google_pies(data, "site_customer"))
    end

    @sro_by_site_reason.each do |site, data|
      @sro_by_site_reason_pie[site] = Sro.sort_for_legend(Sro.build_data_for_google_pies(data, "site_reason"))
    end

    @sro_by_site_item.each do |site, data|
      @sro_by_site_item_pie[site] = Sro.sort_for_legend(Sro.build_data_for_google_pies(data, "site_item"))
    end

    @sro_by_failure_code_pie = Sro.sort_for_legend(Sro.build_data_for_google_pies(@sro_by_failure_code, "failure_code"))
    @sro_by_failure_code_sites_pie = Sro.sort_for_legend(Sro.build_data_for_google_pies(@sro_by_failure_code, "failure_code", "by_grand_total"))
    @sro_by_failure_code = @sro_by_failure_code.sort_by {|key, value| value["Total"]}
  end

  def show
    @start_date = (Date.today.beginning_of_week - 1.week).strftime("%D")
    @end_date = (Date.today.end_of_week - 1.week).strftime("%D")
    @sro_by_responsibility = Hash.new

    Responsibility.all.each do |responsibility|
      @sro_by_failure = Hash.new
      responsibility.failure_codes.each {|code| @sro_by_failure["#{code.name}"] = Array.new}
      @sro_by_responsibility["#{responsibility.name}"] = @sro_by_failure
    end

    #Pulls Data from QAD through API call.
    uri = URI(self.api_url + "/sro/order_entry?start=#{@start_date}&end=#{@end_date}")
    response = Net::HTTP.get(uri)

    #Cycles through returned data and builds Hash of totals to display
    JSON.parse(response)["sros"].each do |sros|
      #Builds data based on Responsibility Specifications
      @sro_by_responsibility = Sro.build_by_responsibility(sros, @sro_by_responsibility)
    end

    @sro_by_responsibility.values[0] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[0])
    @sro_by_responsibility.values[1] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[1])
    @sro_by_responsibility.values[2] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[2])
    @sro_by_responsibility.values[3] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[3])
    @sro_by_responsibility.values[4] = Sro.total_all_data_by_responsibility(@sro_by_responsibility.values[4])
    @sro_by_responsibility["Grand Total"] = {"Grand Total" => Sro.totals_by_site}
    @sro_responsibiilty_pie = Sro.build_data_for_google_pies(@sro_by_responsibility, "responsibility")
    @sro_responsibility_sites_pie = Sro.build_data_for_google_pies(@sro_by_responsibility, "responsibility", "by_grand_total")
    
  
    SroByResponsibilityMailer.responsibility_email(self.api_url).deliver
    
  end
end


