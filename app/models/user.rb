class User < ActiveRecord::Base
	#set_primary_key :klucz
	validates :klucz, :presence => true
end
