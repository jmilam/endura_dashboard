class ItExpenseController < ApplicationController
  def index
  	uri = URI("http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/xxapigldashboard.p?date=#{(Date.today - 1.day).strftime('%m-%d-%Y')}")
    p @response = Net::HTTP.get(uri)
		# p @data = JSON.parse(@response)
  	
  end
end
