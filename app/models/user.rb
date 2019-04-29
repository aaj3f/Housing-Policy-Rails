class User < ApplicationRecord

  def calculate_median_income
    base_url = 'https://api.census.gov'
    queries = '/data/2017/acs/acs5?get=B19013_001E&for=zip%20code%20tabulation%20area:' + self.zipcode.to_s + '&key=' + ENV['CENSUS_API_KEY']
    url = base_url + queries
    uri = URI(url)
    response = Net::HTTP.get(uri)
    json_response = JSON.parse(response)
    median_income = json_response[1][0]
    median_income
  end

  # TODO: change so that median income is persisted
  def qualifies_for_warren?
    self.salary < 1.2 * self.calculate_median_income.to_i
  end
end
