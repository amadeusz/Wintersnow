module ApplicationHelper
	PL_DAYS = [nil,'poniedziałek','wtorek','środa','czwartek','piatek','sobota','niedziela']
	PL_MONTHS = [nil,'stycznia','lutego','marca','kwietnia','maja','czerwca','lipca','sierpnia','września','października','listopada','grudnia']
	Calendar_Polibuda = {
		"20-04-2011" => "zajęcia jak w piątek parzysty",
		"16-05-2011" => "zajęcia jak w piątek nieparzysty",
		}
	Calendar_Inne = {
		"18-05-2011" => "Pomyślnie dodano kalendarz :)" 
		}
	def skroc_date(data)
		return data.to_s[2, data.to_s.length-11]
	end
	
	def przed_slashem(str)
		return str[0, str.index('/', 10)]
	end
	
	def po_slashu(str)
		return str[str.index('/', 10) +1, str.length]
	end

	def get_opis (address, user_id)
		adres = address.sites.where({:user_id => user_id}).first
		if adres.nil? == false and adres.opis != nil
			adres.opis 
		else 
			address.opis
		end
	end
	
end
