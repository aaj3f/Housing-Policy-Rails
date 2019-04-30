# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


if FreeMarketRentInfo.all.size == 0
  xls = Roo::Excel.new("./FY2015F_4050_Final.xls")
  sheet = xls.sheet(0)
  sheet.each(state: 'State', county: 'county', fmr0: 'fmr0', fmr1: 'fmr1', fmr2: 'fmr2', fmr3: 'fmr3', fmr4: 'fmr4') do |hash|
    FreeMarketRentInfo.create(hash)
  end
  FreeMarketRentInfo.all.first.destroy
end

if ZipCode.all.size == 0
  csv = Roo::Spreadsheet.open('./ZIP-COUNTY-FIPS_2017-06.csv', extension: :csv)
  sheet = csv.sheet(0)
  sheet.each(zipcode: 'ZIP', fips: 'STCOUNTYFP') do |hash|
    string = hash[:fips].dup
    county = string.slice!(-3, 3)
    state = string
    new_hash = { state: state, county: county }
    ZipCode.create(hash.merge(new_hash))
  end
  ZipCode.all.first.destroy
end

# items = FreeMarketRentInfo.all.select {|item| item.zipcode == nil }
#
# items.each do |item|
#   match = ZipCode.find_by(state: item.state, county: item.county)
#   if match
#     zipcode = match.zipcode
#     item.update(zipcode: zipcode)
#   else
#     puts "no match for FreeMarketRentInfo row with id: #{item.id}"
#   end
# end


# TODO: iterate through each FreeMarketRentInfo row, find ZipCode row with same county and state,
# and add zipcode to FreeMarketRentInfo row
# That requires a new column in FreeMarketRentInfo
