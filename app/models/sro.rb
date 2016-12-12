class Sro
  def self.add(total, number)
    (total += number).round(2)
  end
  def self.calculate_all_sros(sro_hash, sro_value)
    if Date.today.year.to_s == sro_value["sro-due-date"].to_date.year.to_s
      #Add it to Year To Date
      sro_hash[:curr_ytd] += sro_value["sro-line-total"].round(2)
      #Add it to Previous Month
      sro_hash[:prev_month] += sro_value["sro-line-total"].round(2) if self.prev_month(sro_value["sro-due-date"])
    elsif (Date.today.year - 1).to_s == sro_value["sro-due-date"].to_date.year.to_s
      #Add it to Previous Year
      p sro_hash
      sro_hash[:prev_year] += sro_value["sro-line-total"].round(2)
      #Add it to Previous YTD
      sro_hash[:prev_ytd] += sro_value["sro-line-total"].round(2) if self.year_to_date(sro_value["sro-due-date"])
    else
    end
    sro_hash    
  end
  def self.year_to_date(due_date)
    due_date.to_date.month <= Date.today.month
  end
  def self.prev_month(due_date)
    due_date.to_date.month == Date.today.month - 1
  end
  def self.add_to_current_sro_data
    
  end
  def self.create_new_sro_data(key, value, data_var)
    data_var[key] = {value => {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}    
  end
end
