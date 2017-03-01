class Sro
  class << self
    attr_accessor :totals_by_site
    attr_accessor :unconf_chart_data
  end

  def self.sort_by_total(value)
    value.sort_by {|key, value| [value[:total], key]}
  end

  def self.build_data_for_google_pies(data, chart, type="by_keys")
    return_data = [["Key", "value"]]
    cycle_count = 0 
    
    if type == "by_keys"
      data.each do |key, value| 
        case chart
        when "responsibility"
          value["Total"].nil? ? 0 : return_data << [key, value["Total"]["Total"].abs.round]
        when "failure_code"
          value["Total"].nil? ? 0 : return_data << [key, value["Total"].abs.round] unless key == "Total"
        when "customer"
          unless key == "Grand Total"
            value["Total"].nil? ? 0 : return_data << [key, value["Total"].abs.round]
          end
        when "site_customer", "site_reason", "site_item"
          unless key.downcase == "total"
            return_data << [key, value[:total].abs.round]
          end
        end
      end
    elsif type == "by_grand_total"
      case chart
      when "responsibility"
        data["Grand Total"]["Grand Total"].each do |key, value|
            unless cycle_count == 0 || key.downcase == "total"
              return_data << [key, value.round]
            end
          cycle_count += 1
        end
      when "failure_code"
        data["Total"].each do |key, value|
          unless cycle_count == 0 || key.downcase == "total"
            return_data << [key, value.round]
          end
          cycle_count += 1
        end
      when "customer"
        data["Grand Total"].each do |key, value|
          unless cycle_count == 0 || key.downcase == "total"
            return_data << [key, value.round]
          end
          cycle_count += 1
        end
      end
    end
    return_data
  end

  def self.build_data_for_google_combo(data)
    return_data = [['Site'], ['2000'], ['3000'],['4300'], ['5000'], ['9000']]

    data.each do |key, value|
      value.keys.each do |customer|
        unless customer.downcase == "total"
          return_data[0] << customer
        end
      end
    end

    return_data[1..return_data.count-1].each {|data_array| data_array.fill(0,1,return_data[0].count - 1)}

    data.each do |key,value|
      value.keys.each do |customer|
        unless customer.downcase == "total"
          array_loc = return_data[0].index(customer)
          case key
          when '2000'
            return_data[2][array_loc] = value[customer][:total]
          when '3000'
            return_data[3][array_loc] = value[customer][:total]
          when '4300'
            return_data[4][array_loc] = value[customer][:total]
          when '5000'
            return_data[5][array_loc] = value[customer][:total]
          when '9000'
            return_data[6][array_loc] = value[customer][:total]
          end
        end
      end
    end

    return_data 
  end

  def self.build_by_responsibility(sros, sro_by_responsibility)
    if sro_by_responsibility.values[0].keys.include?(sros["sro-failure1"])
      if sro_by_responsibility.values[0][sros["sro-failure1"]].empty?
        sro_by_responsibility.values[0][sros["sro-failure1"]] = self.create_by_responsibility(sros["sro-desc"])
      else
        #Add Totals
        sro_by_responsibility.values[0] = self.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], sro_by_responsibility.values[0], sros["sro-line-total"])
      end
    elsif sro_by_responsibility.values[1].keys.include?(sros["sro-failure1"])
      if sro_by_responsibility.values[1][sros["sro-failure1"]].empty?
        sro_by_responsibility.values[1][sros["sro-failure1"]] = self.create_by_responsibility(sros["sro-desc"])
      else
        sro_by_responsibility.values[1] = self.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], sro_by_responsibility.values[1], sros["sro-line-total"])
      end
    elsif sro_by_responsibility.values[2].keys.include?(sros["sro-failure1"])
      if sro_by_responsibility.values[2][sros["sro-failure1"]].empty?
        sro_by_responsibility.values[2][sros["sro-failure1"]] = self.create_by_responsibility(sros["sro-desc"])
      else
        sro_by_responsibility.values[2] = self.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], sro_by_responsibility.values[2], sros["sro-line-total"])
      end
    elsif sro_by_responsibility.values[3].keys.include?(sros["sro-failure1"])
      if sro_by_responsibility.values[3][sros["sro-failure1"]].empty?
        sro_by_responsibility.values[3][sros["sro-failure1"]] = self.create_by_responsibility(sros["sro-desc"])
      else
        sro_by_responsibility.values[3] = self.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], sro_by_responsibility.values[3], sros["sro-line-total"])
      end
    elsif sro_by_responsibility.values[4].keys.include?(sros["sro-failure1"])
      if sro_by_responsibility.values[4][sros["sro-failure1"]].empty?
        sro_by_responsibility.values[4][sros["sro-failure1"]] = self.create_by_responsibility(sros["sro-desc"])
      else
        sro_by_responsibility.values[4] = self.add_values_by_responsibility(sros["xxsro-so-site"], sros["sro-failure1"], sro_by_responsibility.values[4], sros["sro-line-total"])
      end
    end
    sro_by_responsibility
  end

  def self.build_by_customer(sros, sro_by_customer)
    if sro_by_customer.keys.include?(sros["sro-name"])
      sro_by_customer = self.add_values_by_customer(sros["xxsro-so-site"], sros["sro-name"], sro_by_customer, sros["sro-line-total"])
    else
      sro_by_customer[sros["sro-name"]] = self.create_by_customer
    end
    sro_by_customer
  end

  def self.build_by_site_customer(sros, sro_by_site_customer)
    if sro_by_site_customer[sros["xxsro-so-site"]].keys.include?(sros["sro-name"])
      #add to hash
      if sro_by_site_customer[sros["xxsro-so-site"]][sros["sro-name"]][:failure_code] == sros["sro-failure1"]
        sro_by_site_customer[sros["xxsro-so-site"]][sros["sro-name"]][:total] += sros["sro-line-total"]
      else
        sro_by_site_customer[sros["xxsro-so-site"]][sros["sro-name"]][:failure_code] = sros["sro-failure1"]
        sro_by_site_customer[sros["xxsro-so-site"]][sros["sro-name"]][:total] = sros["sro-line-total"]
      end 
    else
      sro_by_site_customer[sros["xxsro-so-site"]][sros["sro-name"]] = {failure_code: sros["sro-failure1"], total: sros["sro-line-total"]}
    end
    sro_by_site_customer[sros["xxsro-so-site"]]["Total"][:total] += sros["sro-line-total"]
    sro_by_site_customer["Total"]["Total"][:total] += sros["sro-line-total"]
    sro_by_site_customer
  end

  def self.build_by_site_reason(sros, sro_by_site_reason)
    if sro_by_site_reason[sros["xxsro-so-site"]].keys.include?(sros["sro-failure1"])
      sro_by_site_reason[sros["xxsro-so-site"]][sros["sro-failure1"]][:total] += sros["sro-line-total"]
    else
      sro_by_site_reason[sros["xxsro-so-site"]][sros["sro-failure1"]] = {reason: sros["sro-desc"], total: sros["sro-line-total"]}
    end
    sro_by_site_reason[sros["xxsro-so-site"]]["Total"][:total] += sros["sro-line-total"]
    sro_by_site_reason["Total"]["Total"][:total] += sros["sro-line-total"]
    sro_by_site_reason
  end

  def self.build_by_site_item(sros, sro_by_site_item)
    if sro_by_site_item[sros["xxsro-so-site"]].keys.include?(sros["srod-group"])
      sro_by_site_item[sros["xxsro-so-site"]][sros["srod-group"]][:total] += sros["sro-line-total"]
    else
      sro_by_site_item[sros["xxsro-so-site"]][sros["srod-group"]] = {reason: sros["sro-desc"], total: sros["sro-line-total"]}
    end
    sro_by_site_item[sros["xxsro-so-site"]]["Total"][:total] += sros["sro-line-total"]
    sro_by_site_item["Total"]["Total"][:total] += sros["sro-line-total"]
    sro_by_site_item
  end

  def self.build_by_failure_code(sros, sro_by_failure_code)
    site = sros["xxsro-so-site"]

    if sro_by_failure_code.keys.include?(sros["sro-failure1"])
      #add to toals
      sro_by_failure_code[sros["sro-failure1"]][site] += sros["sro-line-total"]
    else
      sro_by_failure_code[sros["sro-failure1"]] = {reason: sros["sro-desc"], "2000" => 0, "3000" => 0, "4300" => 0, "5000" => 0, "9000" => 0, "Total" => 0}
      sro_by_failure_code[sros["sro-failure1"]][site] = sros["sro-line-total"]
    end
    sro_by_failure_code[sros["sro-failure1"]]["Total"] += sros["sro-line-total"]
    sro_by_failure_code["Total"][site] += sros["sro-line-total"]
    sro_by_failure_code["Total"]["Total"] += sros["sro-line-total"]
    sro_by_failure_code
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
    {"description" => ["#{description}"], "2000" => 0.00, "3000" => 0.00, "4300" => 0.00, "5000" => 0.00, "9000" => 0.00, "Total" => 0.00}
  end

  def self.create_by_customer
    {"2000" => 0.00, "3000" => 0.00, "4300" => 0.00, "5000" => 0.00, "9000" => 0.00, "Total" => 0.00}
  end

  def self.add_values_by_responsibility(site, failure_code, hash_by_responsibility, line_total)
    case site
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

  def self.add_values_by_customer(site, customer, hash_by_customer, line_total)
    case site
    when "2000"
      hash_by_customer[customer][site] += line_total
    when "3000"
      hash_by_customer[customer][site] += line_total
    when "4300"
      hash_by_customer[customer][site] += line_total
    when "5000"
      hash_by_customer[customer][site] += line_total
    when "9000"
      hash_by_customer[customer][site] += line_total
    end
    hash_by_customer[customer]["Total"] += line_total
    hash_by_customer
  end

  def self.total_all_data_by_responsibility(hash_by_responsibility)
    grand_total = {"description" => ["-"], "2000" => 0.00, "3000" => 0.00, "4300" => 0.00, "5000" => 0.00, "9000" => 0.00, "Total" => 0.00}
    hash_by_responsibility.each do |key, value|
      value.each do |site, total|
        case site
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
        unless site.downcase == "total"
          grand_total["Total"] += total unless total.class == Array
        end
      end
    end
    self.total_all_data_by_site(grand_total)
    hash_by_responsibility["Total"] = grand_total
    
    hash_by_responsibility
  end

  def self.total_all_data_by_site(hash_by_site)
    if @totals_by_site.nil?
      @totals_by_site = {"description" => ["-"], "2000" => 0.00, "3000" => 0.00, "4300" => 0.00, "5000" => 0.00, "9000" => 0.00, "Total" => 0.00}
    end
    @totals_by_site["2000"] += hash_by_site["2000"]
    @totals_by_site["3000"] += hash_by_site["3000"]
    @totals_by_site["4300"] += hash_by_site["4300"]
    @totals_by_site["5000"] += hash_by_site["5000"]
    @totals_by_site["9000"] += hash_by_site["9000"]
    @totals_by_site["Total"] += hash_by_site["Total"]
    @totals_by_site
  end

  def self.group_unconfirmed(unconf_ords, exceptions)
    group_ords = Hash.new
    @unconf_chart_data = Array.new
    users = ['Year']

    unconf_ords.each do |unconf|
      unless exceptions.include?(unconf['ttunuserid'].downcase)
        users.include?(unconf['ttunuserid']) ? next : users << unconf['ttunuserid']
        group_ords.keys.include?(unconf['ttunuserid']) ? next : group_ords["#{unconf['ttunuserid']}"] = {'Monday' => 0, 'Tuesday' => 0, 'Wednesday' => 0, 'Thursday' => 0,'Friday' => 0, 'Saturday' => 0}
      end
    end
    group_ords["Total"] = {'Monday' => 0, 'Tuesday' => 0, 'Wednesday' => 0, 'Thursday' => 0,'Friday' => 0, 'Saturday' => 0}

    @unconf_chart_data << users
    self.buildGroupArrays(users.count-1).each {|data| @unconf_chart_data << data}

    unconf_ords.each do |unconf|
      unless exceptions.include?(unconf['ttunuserid'].downcase)
        date = unconf["ttundate"].to_date.strftime("%u")
        self.AppendData(@unconf_chart_data, @unconf_chart_data[0].index(unconf['ttunuserid']), unconf['ttuncnt'], date)
        group_ords[unconf['ttunuserid']][unconf["ttundate"].to_date.strftime("%A")] += unconf['ttuncnt']
        group_ords["Total"][unconf["ttundate"].to_date.strftime("%A")] += unconf['ttuncnt']
      end
    end

    [group_ords, @unconf_chart_data]
  end

  def self.buildGroupArrays(usr_count)
    [['Mon'], ['Tues'], ['Wed'], ['Thurs'], ['Fri'], ['Sat']].each do |day|
      day.fill(0, 1..usr_count)
    end
  end

  def self.AppendData(data_group, idx, count, array_location)
    data_group[array_location.to_i][idx] = count
  end
end
