class CreateZipCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :zip_codes do |t|
      t.integer :zipcode
      t.integer :county
      t.integer :state

      t.timestamps
    end
  end
end
