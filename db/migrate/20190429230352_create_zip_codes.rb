class CreateZipCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :zip_codes do |t|
      t.integer :zipcode
      t.string :county
      t.string :state

      t.timestamps
    end
  end
end
