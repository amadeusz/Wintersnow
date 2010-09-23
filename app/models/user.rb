class User < ActiveRecord::Base
	validates :klucz, :uniqueness => true, :presence => true
	has_many :sites
	has_many :addresses, :through => :sites
end
