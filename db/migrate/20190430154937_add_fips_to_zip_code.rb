class AddFipsToZipCode < ActiveRecord::Migration[5.2]
  def change
    add_column :zip_codes, :fips, :string
  end
end
