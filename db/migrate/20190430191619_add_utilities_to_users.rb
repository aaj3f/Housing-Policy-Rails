class AddUtilitiesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :utilities, :integer, default: 0
  end
end
