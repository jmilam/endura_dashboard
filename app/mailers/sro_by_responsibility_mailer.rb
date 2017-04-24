class SroByResponsibilityMailer < ApplicationMailer
	require 'net/http'
	default from: 'alerts@enduraproducts.com.com'
 
  def responsibility_email(url, image_files)
    @image_files = image_files

  	@start_date = (Date.today.beginning_of_week - 1.week).strftime("%D")
    @end_date = (Date.today.end_of_week - 1.week).strftime("%D")
    @sro_by_responsibility = Hash.new

    Responsibility.all.each do |responsibility|
      @sro_by_failure = Hash.new
      responsibility.failure_codes.each {|code| @sro_by_failure["#{code.name}"] = Array.new}
      @sro_by_responsibility["#{responsibility.name}"] = @sro_by_failure
    end

    #Pulls Data from QAD through API call.
    uri = URI(url + "/sro/order_entry?start=#{@start_date}&end=#{@end_date}")
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
    
    @image_files.each do |image_url|
      attachments.inline["#{image_url}"] = File.read("#{Rails.root}/app/assets/images/#{image_url}")
      attachments.inline["#{image_url}"] = File.read("#{Rails.root}/app/assets/images/#{image_url}")
    end

    # mail(to: 'jmilam@enduraproducts.com', subject: 'Responsibilities snapshot')
    mail(to: 'gpiersanti@enduraproducts.com,tbell@enduraproducts.com,jmilam@enduraproducts.com', subject: 'Responsibilities snapshot')

    @image_files.each do |image_url|
      File.delete("#{Rails.root}/app/assets/images/#{image_url}")
    end
  end


end
