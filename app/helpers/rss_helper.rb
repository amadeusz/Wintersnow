module RssHelper
	def news(user)
		news = []
		User.find(user).addresses.each {|adres|
			news += adres.messages.where("data >= ?",user.created_at).order("data DESC")
		}
		news
	end
end
