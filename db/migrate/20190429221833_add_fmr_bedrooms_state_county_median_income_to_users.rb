class AddFmrBedroomsStateCountyMedianIncomeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :fmr, :integer
    add_column :users, :bedrooms, :integer
    add_column :users, :state, :string
    add_column :users, :county, :string
    add_column :users, :median_income, :integer
  end
end
