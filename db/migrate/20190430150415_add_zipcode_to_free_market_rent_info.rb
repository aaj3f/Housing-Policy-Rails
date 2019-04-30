class AddZipcodeToFreeMarketRentInfo < ActiveRecord::Migration[5.2]
  def change
    add_column :free_market_rent_infos, :zipcode, :integer
  end
end
