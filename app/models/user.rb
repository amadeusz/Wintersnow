class User < ActiveRecord::Base
	validates :klucz, :uniqueness => true, :presence => true
end
