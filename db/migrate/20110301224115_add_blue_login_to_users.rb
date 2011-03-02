class AddBlueLoginToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fire_login, :string
    add_column :users, :fire_password, :string
    add_column :users, :water_login, :string
    add_column :users, :water_password, :string
    add_column :users, :air_login, :string
    add_column :users, :air_password, :string
    add_column :users, :earth_login, :string
    add_column :users, :earth_password, :string
    remove_column :users, :pwr_index
    remove_column :users, :pwr_password
  end

  def self.down
    remove_column :users, :fire_login, :string
    remove_column :users, :fire_password, :string
    remove_column :users, :water_login, :string
    remove_column :users, :water_password, :string
    remove_column :users, :air_login, :string
    remove_column :users, :air_password, :string
    remove_column :users, :earth_login, :string
    remove_column :users, :earth_password, :string
    add_column :users, :pwr_index
    add_column :users, :pwr_password
  end
end
