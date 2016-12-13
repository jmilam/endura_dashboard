class Sro
  def self.add(total, number)
    (total += number).round(2)
  end

  def self.calculate_all_sros(sro_hash, sro_value)
    if Date.today.year.to_s == sro_value["sro-ent-date"].to_date.year.to_s
      #Add it to Year To Date
      sro_hash[:curr_ytd] += sro_value["sro-line-total"].round(2)
      #Add it to Previous Month
      sro_hash[:prev_month] += sro_value["sro-line-total"].round(2) if self.prev_month(sro_value["sro-ent-date"])
      sro_hash[:curr_month] += sro_value["sro-line-total"].round(2) if self.curr_month(sro_value["sro-ent-date"])
    elsif (Date.today.year - 1).to_s == sro_value["sro-ent-date"].to_date.year.to_s
      #Add it to Previous Year
      sro_hash[:prev_year] += sro_value["sro-line-total"].round(2)
      #Add it to Previous YTD
      sro_hash[:prev_ytd] += sro_value["sro-line-total"].round(2) if self.year_to_date(sro_value["sro-ent-date"])
    else
    end
    sro_hash    
  end

  def self.year_to_date(due_date)
    due_date = due_date.to_date
    curr_date = Date.today
    due_date <= curr_date 
  end

  def self.prev_month(due_date)
    due_date = due_date.to_date
    curr_date = Date.today
    due_date.month == curr_date.month - 1  
  end

  def self.curr_month(due_date)
    due_date = due_date.to_date
    curr_date = Date.today
    due_date.month == curr_date.month && due_date.year == curr_date.year
  end

  def self.calculate_customer_ytd(total, amount, due_date)
    due_date = due_date.to_date
    curr_date = Date.today
    if due_date.month <= curr_date.month && due_date.year == curr_date.year
      total += amount
    end
    total
  end

  def self.sort_data(data)
    data.each do |key, value| 
      data[key] = value.sort_by {|key, value| key}.to_h
    end
    data
  end
end
