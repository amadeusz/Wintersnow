module RssHelper
	def news(user)
		news = []
		User.find(user).addresses.each {|adres|
			news += adres.messages
		}
		news.sort! { |a,b| b.data <=> a.data }
	end
end
