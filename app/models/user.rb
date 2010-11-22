class User < ActiveRecord::Base
	validates :klucz, :uniqueness => true, :presence => true
	has_many :sites
	has_many :addresses, :through => :sites
	
	before_create :generate_rss_pass
	
	def messages
		Message.find_by_sql("SELECT m.*
		FROM sites s, addresses a, messages m
		WHERE s.user_id = #{id} AND s.address_id = a.id AND m.address_id = a.id AND m.data >= \"#{created_at}\"
		ORDER BY m.data DESC")
	end
	
	private
		def generate_rss_pass
			self.rss_pass = (Digest::SHA2.new() << (self.klucz + rand(100).to_s)).to_s[1..20]
		end
end
