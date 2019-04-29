class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :ip_address
      t.integer :zipcode
      t.integer :salary
      t.integer :rent_cost

      t.timestamps
    end
  end
end
