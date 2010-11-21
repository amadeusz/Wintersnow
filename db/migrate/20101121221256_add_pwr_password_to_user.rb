class AddPwrPasswordToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :pwr_password, :string
  end

  def self.down
    remove_column :users, :pwr_password
  end
end
