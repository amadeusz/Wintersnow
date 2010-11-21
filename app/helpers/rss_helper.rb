module RssHelper
	def news(user)
	
		news = []
		if user.created_at != nil then
			User.find(user).addresses.each { |adres|
				news += adres.messages.where("data >= ?", user.created_at).order("data DESC")
			}
		else
			User.find(user).addresses.each { |adres|
				news += adres.messages.order("data DESC")
			}	
		end
		news
		
	end
end
