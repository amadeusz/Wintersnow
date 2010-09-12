class AddAddressIdToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :address_id, :integer
  end

  def self.down
    remove_column :messages, :address_id
  end
end
