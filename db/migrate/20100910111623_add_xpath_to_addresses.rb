class AddXpathToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :xpath, :string
  end

  def self.down
    remove_column :addresses, :xpath
  end
end
