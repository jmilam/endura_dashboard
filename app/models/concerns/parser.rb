class Parser
	def which_quarter(quarters)
  	q1 = {}
  	q2 = {}
  	q3 = {}
  	q4 = {}
  	
  	quarters.each do |key, value|
  		if key.match(/1/)
  			start_end(q1, key, value)
  		elsif key.match(/2/)
  			start_end(q2, key, value)
  		elsif key.match(/3/)
  			start_end(q3, key, value)
  		elsif key.match(/4/)
  			start_end(q4, key, value)
  		end	
  	end

		{q1: q1, q2: q2, q3: q3, q4: q4}
  end

  def start_end(quarter, key, value)
  	if key.match(/start/)
			quarter[:start] = value
		else
			quarter[:end] = value
		end
		quarter
	end

	def add_to_quarter(quarter_hash, value, current_value)
		return_value = current_value
		quarter_hash.each do |key, date|
			date_start = Date.parse(date[:start])
			date_end = Date.parse(date[:end])
			if Date.parse(value["ttpostdate"]).between?(date_start, date_end)
				if return_value[key].nil? 
				 	return_value[key] = {debits: value["ttdebit"], credits: value["ttcredit"]}
				else
					return_value[key][:debits] += value["ttdebit"]
					return_value[key][:credits] += value["ttcredit"]
				end

				next
			else
			end	
		end
		return_value
	end
end