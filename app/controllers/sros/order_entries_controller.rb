class Sros::OrderEntriesController < ApplicationController
	def index
	  #Initial Values set for variables
	  @performance_data = Array.new
	  @user_names = ['Order Type']
	  @auto_orders = ['Auto Orders']
	  @manual_orders = ['Manual Orders']
	  @auto_lines = ['Auto Lines']
	  @manual_lines = ['Manual Lines']
	
	  #URI call to QAD API to receive JSON data
	  uri = URI("http://qadprod.endura.enduraproducts.com/cgi-bin/prodapi/xxapioesrodashboard.p?start=#{params[:start_date]}&end=#{params[:end_date]}")
	  response = Net::HTTP.get(uri)
	  json_response =  JSON.parse(response)
	  @user_stats = json_response["userstats"]
	  
	  #This cycles the returned JSON data from QAD and builds an Array for Google Chart Visualization
	  @user_stats.each do |stats|
	    @user_names << stats["t_userid"]
	    @auto_orders << (stats["t_edi_ord"] + stats["t_scn_ord"])
            @manual_orders << stats["t_man_ord"]
	    @auto_lines << (stats["t_edi_line"] + stats["t_scn_line"])
	    @manual_lines << stats["t_man_line"]
	  end
	  
	  @performance_data << @user_names
	  @performance_data << @auto_orders
	  @performance_data << @manual_orders
	  @performance_data << @auto_lines
	  @performance_data << @manual_lines
	end
end
