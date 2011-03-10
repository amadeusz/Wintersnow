class String
	def limit(length)
		str = self.to_s
		( str = str[0, length-3] + '...' ) if self.length > length
		str
	end
	
	def md5
		Digest::MD5.hexdigest(self)
	end
	
	def sha
		(Digest::SHA2.new() << self).to_s
	end
end

#	def sklejenie_warunkowe(elementy)
#		elementy = elementy.find_all{ |element| element != '' }
#		elementy.join(' ').to_s
#	end
