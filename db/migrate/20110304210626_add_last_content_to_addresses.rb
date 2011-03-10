class AddLastContentToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :last_content, :string
    add_column :addresses, :last_content_type, :string
    add_column :addresses, :last_content_checksum, :string
  end

  def self.down
    remove_column :addresses, :last_content
    remove_column :addresses, :last_content_type
    remove_column :addresses, :last_content_checksum
  end
end
