class AddPwrIndexToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :pwr_index, :string
  end

  def self.down
    remove_column :users, :pwr_index
  end
end
