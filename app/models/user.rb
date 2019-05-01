class User < ApplicationRecord
  after_create do |user|
    user.calculate_median_income
    user.calculate_fmr
    if [user.qualifies_for_warren?, user.qualifies_for_booker?, user.qualifies_for_harris?].any? { |flag| flag }
      puts "You qualify for benefits under the following candidate\'s policies: "
      puts "\tElizabeth Warren" if user.qualifies_for_warren?
      puts "\tCory Booker" if user.qualifies_for_booker?
      puts "\tKamala Harris" if user.qualifies_for_harris?
    else
      puts "You don\'t seem to qualify for benefits under any of the housing crisis policies proposed so far."
    end
    user.calculate_booker_credit if user.qualifies_for_booker?
    user.calculate_harris_credit if user.qualifies_for_harris?
  end

  def calculate_median_income
    base_url = 'https://api.census.gov'
    queries = '/data/2017/acs/acs5?get=B19013_001E&for=zip%20code%20tabulation%20area:' + self.zipcode.to_s + '&key=' + ENV['CENSUS_API_KEY']
    url = base_url + queries
    uri = URI(url)
    response = Net::HTTP.get(uri)
    json_response = JSON.parse(response)
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
    self.salary < 1.2 * self.median_income
  end

  def qualifies_for_booker?
    (self.salary / 12) * 0.3 < self.rent_cost && (self.salary / 12) * 0.3 < self.fmr
  end

  def qualifies_for_harris?
    (self.rent_cost < self.fmr * 1.5) && self.salary <= 100000
  end

  def calculate_booker_credit
    return 0 unless self.qualifies_for_booker?
    thirty_percent_monthly_income = (self.salary / 12) * 0.3
    rent_evaluation = [self.rent_cost, self.fmr].min
    excess_rent_costs = rent_evaluation - thirty_percent_monthly_income
    credit = excess_rent_costs > 0 ? excess_rent_costs.round(2) : 0
    puts "Cory Booker's policy would provide you a tax credit of $#{credit} / month" if credit > 0
    credit
  end

  def calculate_harris_credit
    return 0 unless self.qualifies_for_harris?
    if (75000 < self.salary && self.salary <= 100000)
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
    puts "Kamala Harris's policy would provide you a tax credit of $#{credit} / month" if credit > 0
    credit
  end

end
