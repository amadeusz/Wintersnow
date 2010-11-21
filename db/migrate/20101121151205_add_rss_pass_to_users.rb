class AddRssPassToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :rss_pass, :string
    User.update_all ["rss_pass = ?", (Digest::SHA2.new() << rand(100).to_s).to_s[1..20]] 
  end

  def self.down
    remove_column :users, :rss_pass
  end
end
