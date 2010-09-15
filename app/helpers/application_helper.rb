module ApplicationHelper

	def skroc_date(data)
		return data.to_s[2, data.to_s.length-11]
	end
	
	def przed_slashem(str)
		return str[0, str.index('/', 10)]
	end
	
	def po_slashu(str)
		return str[str.index('/', 10) +1, str.length]
	end

end
