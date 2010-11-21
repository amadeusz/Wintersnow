class User < ActiveRecord::Base
	validates :klucz, :uniqueness => true, :presence => true
	has_many :sites
	has_many :addresses, :through => :sites
	
	before_create :generate_rss_pass
	
	private
		def generate_rss_pass
			self.rss_pass = (Digest::SHA2.new() << (self.klucz + rand(100).to_s)).to_s[1..20]
		end
end
