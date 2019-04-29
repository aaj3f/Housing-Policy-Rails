class CreateFreeMarketRentInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :free_market_rent_infos do |t|
      t.string :state
      t.string :county
      t.integer :fmr0
      t.integer :fmr1
      t.integer :fmr2
      t.integer :fmr3
      t.integer :fmr4

      t.timestamps
    end
  end
end
