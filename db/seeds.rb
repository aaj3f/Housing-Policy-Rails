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
  sheet.each(state: 'state_alpha', county: 'countyname', fmr0: 'fmr0', fmr1: 'fmr1', fmr2: 'fmr2', fmr3: 'fmr3', fmr4: 'fmr4') do |hash|
    FreeMarketRentInfo.create(hash)
  end
end
