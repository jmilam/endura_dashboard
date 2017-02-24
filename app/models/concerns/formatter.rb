class Formatter

  def self.from_oe_report_card(data)
  	return_array = [["User Name"], ["Auto Orders"], ["Manual Orders"], ["Auto Lines"], ["Manual Lines"]]
  	data.each do |key, value|
  		return_array[0] << value["emp"]
  		return_array[1] << value["auto_orders"]
  		return_array[2] << value["man_orders"]
  		return_array[3] << value["auto_lines"]
  		return_array[4] << value["man_lines"]
  	end
  	return_array
  end

  def self.format_errors(errors)
    error_array = Array.new
    errors.to_a.each do |message|           
      message[1].each do |desc|                
        error_array << "#{message[0].to_s.capitalize.gsub("_", " ")} #{desc}"
      end
    end
    error_array
  end
end