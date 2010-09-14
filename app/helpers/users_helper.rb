module UsersHelper
	def get_opis (address, user_id)
		adres = address.sites.where({:user_id => user_id}).first
		if adres.nil? == false and adres.opis != nil
			adres.opis 
		else 
			address.opis
		end
	end
end
