require 'composite_primary_keys'
class User < ActiveRecord::Base
	set_primary_keys :klucz
end
