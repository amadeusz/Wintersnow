String.class_eval do
	def limit(length)
		str = self.to_s
		( str = str[0, length-3] + '...' ) if self.length > length
		str
	end
end
