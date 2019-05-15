class User < ApplicationRecord
  after_create do |user|
    user.calculate_median_income
    user.calculate_fmr
  end

  def calculate_median_income
    base_url = 'https://api.census.gov'
    queries = '/data/2017/acs/acs5?get=B19013_001E&for=zip%20code%20tabulation%20area:' + self.zipcode.to_s + '&key=' + ENV['CENSUS_API_KEY']
    url = base_url + queries
    uri = URI(url)
    response = Net::HTTP.get(uri)
    json_reposne = nil
    begin
      json_response = JSON.parse(response)
    rescue
      self.errors.add(:median_income, "is not available because of an error with the Census Bureau\'s website.")
      return
    end
    median_income = json_response[1][0]
    self.update(median_income: median_income.to_i)
  end

  def calculate_fmr
    case self.bedrooms
    when 0
      fmr_column = 'fmr0'
    when 1
      fmr_column = 'fmr1'
    when 2
      fmr_column = 'fmr2'
    when 3
      fmr_column = 'fmr3'
    when 4
      fmr_column = 'fmr4'
    end
    zip_info = ZipCode.find_by(zipcode: self.zipcode)
    fmr_info = FreeMarketRentInfo.find_by(state: zip_info.state, county: zip_info.county)
    fmr = fmr_info[fmr_column]
    self.update(fmr: fmr, state: zip_info.state, county: zip_info.county)
  end

  def qualifies_for_warren?
    # if income is less than 120% median income
    self.salary < 1.2 * self.median_income
  end

  def qualifies_for_booker?
    # If rent costs are more than 30% of income
    (self.salary / 12) * 0.3 < [self.rent_cost, self.fmr].min
  end

  def qualifies_for_harris?
    # You won't qualify if you pay more than 150% the evaluated FMR in an area
    (self.rent_cost < self.fmr * 1.5) && self.salary <= 125000
  end

  def calculate_booker_credit
    # credit increases as income decreases and as rent cost increases
    return 0 unless self.qualifies_for_booker?
    thirty_percent_monthly_income = (self.salary / 12) * 0.3
    rent_evaluation = [self.rent_cost, self.fmr].min
    excess_rent_costs = rent_evaluation - thirty_percent_monthly_income
    excess_rent_costs > 0 ? excess_rent_costs.round(2) : 0
  end

  def calculate_harris_credit
    # credit increases as salary decreases
    return 0 unless self.qualifies_for_harris?
    if (75000 < self.salary && self.salary <= 125000)
      credit_modifier = 0.25
    elsif (50000 < self.salary && self.salary <= 75000)
      credit_modifier = 0.5
    elsif (25000 < self.salary && self.salary <= 50000)
      credit_modifier = 0.75
    else
      credit_modifier = 1
    end
    thirty_percent_monthly_income = (self.salary / 12) * 0.3
    rent_cost = self.rent_cost + self.utilities
    excess_rent_costs = rent_cost - thirty_percent_monthly_income
    credit = excess_rent_costs > 0 ? (excess_rent_costs * credit_modifier).round(2) : 0
    credit
  end

  def calculate_warren_graph_data
    user = self.qualifies_for_warren? ? self : User.new( self.attributes.merge({ salary: self.median_income - 1000 }) )
    [ user.salary ]
  end

  def calculate_booker_graph_data
    if self.qualifies_for_booker?
      user_high = self
      is_user = true
    else
      user_high = User.new( self.attributes.merge({ rent_cost: self.fmr, salary: self.fmr * 40 - 1000 }) )
      is_user = false
    end
    user_mid = User.new( user_high.attributes.merge({ salary: 0.8 * user_high.salary }) )
    user_low = User.new( user_high.attributes.merge({ salary: 0.6 * user_high.salary }) )
    [ { salary: user_low.salary, credit: user_low.calculate_booker_credit }, { salary: user_mid.salary, credit: user_mid.calculate_booker_credit }, { salary: user_high.salary, credit: user_high.calculate_booker_credit, flag: is_user } ]
  end

  def calculate_harris_graph_data
    if self.qualifies_for_harris?
      user_high = self
      is_user = true
    else
      user_high = User.new( self.attributes.merge({ rent_cost: 1.4 * self.fmr, salary: self.median_income - 1000 }) )
      is_user = false
    end
    user_mid = User.new( user_high.attributes.merge({ salary: 0.8 * user_high.salary }) )
    user_low = User.new( user_high.attributes.merge({ salary: 0.6 * user_high.salary }) )
    [ { salary: user_low.salary, credit: user_low.calculate_harris_credit }, { salary: user_mid.salary, credit: user_mid.calculate_harris_credit }, { salary: user_high.salary, credit: user_high.calculate_harris_credit, flag: is_user } ]
  end

end
