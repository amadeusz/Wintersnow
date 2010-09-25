class AddPrivateToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :private, :boolean
  end

  def self.down
    remove_column :addresses, :private
  end
end
