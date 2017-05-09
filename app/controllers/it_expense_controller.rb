class ItExpenseController < ApplicationController
  def index
  	@departments = Array.new
  	@parser = Parser.new
  	uri = URI("http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/xxapigldashboard.p?date=#{(Date.today - 1.day).strftime('%m-%d-%Y')}")
    @response = Net::HTTP.get(uri)
		@data = JSON.parse(@response)
  	
		@debits = 0
		@credits = 0
		@deb_cred_by_dept = Hash.new
		@deb_cred_by_qrt = Hash.new
		@qrt_deb_cred = [["Quarter", "Debit", "Credit"]]
		@deb_cred = [["Department", "Debits", "Credits"]]
  	
  	quarters = @parser.which_quarter(@data["Quarters"][0])

  	@gl = @data["GL"].sort_by {|value| value["ttcc"]}
  	
  	@gl.each do |gl|
  		@departments << gl["ttcc"] unless @departments.include?(gl["ttcc"])
  		@debits += gl["ttdebit"]
  		@credits += gl["ttcredit"]
  		
  		if @deb_cred_by_dept[gl["ttcc"]].nil?
  			@deb_cred_by_dept[gl["ttcc"]] = {debits: gl["ttdebit"], credits: gl["ttcredit"]}
  		else
  			@deb_cred_by_dept[gl["ttcc"]][:debits] += gl["ttdebit"]
  			@deb_cred_by_dept[gl["ttcc"]][:credits] += gl["ttcredit"]
  		end

  		@deb_cred_by_qrt = @parser.add_to_quarter(quarters, gl, @deb_cred_by_qrt)
  	end

  	@deb_cred_by_dept.each do |key, value|
  		@deb_cred << ["#{key}", value[:debits].round(2), value[:credits].round(2)]
  	end

  	@deb_cred_by_qrt.each do |key, value|
  		@qrt_deb_cred << ["#{key}", value[:debits].round(2), value[:credits].round(2)]
  	end

  	@total_deb_cred = [["Type", "Amount"], ["Debits", @debits.round(2)], ["Credits", @credits.round(2)]]
  	@budget = @data["Budget"].sort_by {|value| value["ttbudacct"]}
  end
end
