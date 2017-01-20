class Sro
  class << self
    attr_accessor :totals_by_site
  end

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

  def self.calculate_customer_ytd(total, amount, date)
    total += amount.to_f
  end

  # def self.calculate_customer_ytd(curr_data, total, amount, due_date=nil, site=nil)
  #   due_date = due_date.to_date
  #   curr_date = Date.today
  #   if due_date.month <= curr_date.month && due_date.year == curr_date.year
  #     total += amount
  #   end

  #   if curr_data["#{site}"].nil?
  #     {curr_data["#{site}"] => total}
  #   else
  #     {"#{site}" => curr_data["#{site}"] += total} 
  #   end
  # end

  def self.create_sro_with_hash(data_hash, division, sub_group=nil, sro)
    if sub_group.nil?
      data_hash["#{division}"] = {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}
      Sro.calculate_all_sros(data_hash["#{division}"], sro)  
    else
      data_hash["#{division}"] = {"#{sub_group }"=> {curr_month: 0.00, prev_month: 0.00, curr_ytd: 0.00, prev_ytd: 0.00, prev_year: 0.00}}
      Sro.calculate_all_sros(data_hash["#{division}"]["#{sub_group}"], sro)  
    end
  end

  def self.sort_data(data)
    data.each do |key, value| 
      data[key] = value.sort_by {|key, value| key}.to_h
    end
    data
  end

  def self.create_by_responsibility(description)
    {"description" => ["#{description}"], "1000" => 0.00, "2000" => 0.00, "3000" => 0.00, "4300" => 0.00, "5000" => 0.00, "9000" => 0.00, "Total" => 0.00}
  end

  def self.add_values_by_responsibility(site, failure_code, hash_by_responsibility, line_total)
    case site
    when "1000"
      hash_by_responsibility[failure_code][site] += line_total
    when "2000"
      hash_by_responsibility[failure_code][site] += line_total
    when "3000"
      hash_by_responsibility[failure_code][site] += line_total
    when "4300"
      hash_by_responsibility[failure_code][site] += line_total
    when "5000"
      hash_by_responsibility[failure_code][site] += line_total
    when "9000"
      hash_by_responsibility[failure_code][site] += line_total
    end
    hash_by_responsibility[failure_code]["Total"] += line_total
  end

  def self.total_all_data_by_responsibility(hash_by_responsibility)
    grand_total = {"description" => ["-"], "1000" => 0.00, "2000" => 0.00, "3000" => 0.00, "4300" => 0.00, "5000" => 0.00, "9000" => 0.00, "Total" => 0.00}
    hash_by_responsibility.each do |key, value|
      value.each do |site, total|
        case site
        when "1000"
          grand_total["1000"] += total
        when "2000"
          grand_total["2000"] += total
        when "3000"
          grand_total["3000"] += total
        when "4300"
          grand_total["4300"] += total
        when "5000"
          grand_total["5000"] += total
        when "9000"
          grand_total["9000"] += total
        end

        grand_total["Total"] += total unless total.class == Array
      end
    end
    self.total_all_data_by_site(grand_total)
    hash_by_responsibility["Total"] = grand_total
    
    hash_by_responsibility
  end

  def self.total_all_data_by_site(hash_by_site)
    if @totals_by_site.nil?
      @totals_by_site = {"description" => ["-"], "1000" => 0.00, "2000" => 0.00, "3000" => 0.00, "4300" => 0.00, "5000" => 0.00, "9000" => 0.00, "Total" => 0.00}
    end
    @totals_by_site["1000"] += hash_by_site["1000"]
    @totals_by_site["2000"] += hash_by_site["2000"]
    @totals_by_site["3000"] += hash_by_site["3000"]
    @totals_by_site["4300"] += hash_by_site["4300"]
    @totals_by_site["5000"] += hash_by_site["5000"]
    @totals_by_site["9000"] += hash_by_site["9000"]
    @totals_by_site["Total"] += hash_by_site["Total"]
  end
end
