class AddCssToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :css, :string
  end

  def self.down
    remove_column :addresses, :css
  end
end
