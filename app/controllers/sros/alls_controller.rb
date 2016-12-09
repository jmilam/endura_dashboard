class Sros::AllsController < ApplicationController
  def index
    @sro_summary = Hash.new
    @customers = Array.new
    @start_date = (Date.today.beginning_of_week - 1.week).strftime("%D")
    @end_date = (Date.today.end_of_week - 1.week).strftime("%D")
    
    uri = URI(self.api_url + "xxapioesrodashboard.p?start=#{@start_date}&end=#{@end_date}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)["sros"].each do |sros|
      if @sro_summary.keys.include?(sros["sro-name"])
	@sro_summary[sros["sro-name"]][sros["srod-site"]].nil? ? @sro_summary[sros["sro-name"]][sros["srod-site"]] = sros["sro-line-total"] : @sro_summary[sros["sro-name"]][sros["srod-site"]] = Sro.add(@sro_summary[sros["sro-name"]][sros["srod-site"]], sros["sro-line-total"])
        #@sro_summary[sros["sro-name"]]["grand_total"] += sros["srod-line-total"]
	#@sro_summary[sros["sro-name"]]["grand_total"].nil? ? @sro_summary[sros["sro-name"]]["grand_total"] = sros["sro-line-total"] : Sro.add(@sro_summary[sros["sro-name"]]["grand_total"], sros["sro-line-total"])
      else
	@sro_summary[sros["sro-name"]] = {sros["srod-site"] => sros["sro-line-total"]}
	@sro_summary[sros["sro-name"]]["grand_total"].nil? ? @sro_summary[sros["sro-name"]]["grand_total"] = sros["sro-line-total"] : Sro.add(@sro_summary[sros["sro-name"]]["grand_total"], sros["sro-line-total"])
      end
    end
  end
end
