require 'active_record'

def md5(var)
	return Digest::MD5.hexdigest(var)
end

def pobierz(adres)
	Address.update(md5(adres), :data_spr => Time.new )
	return Curl::Easy.perform(adres).body_str
end

def zapisz(adres, zawartosc)
	File.open(RAILS_ROOT+'/db/pobrane/'+ md5(adres), "w") do |f|
		f << zawartosc
	end
end

def skroc(string)
	out = ""
	limit = 50
	szukaj = true
	nastepny = nil
	while szukaj
		if nastepny == nil
			start = string.to_s =~ /<(ins|del)/ 
		else 
			start = nastepny 
		end
		# koniec = string.to_s =~ /<\/(ins|del)/
		if start != nil
			if start - limit > 0
				pierwsza_spacja = string.index(/ /) -1 
				#string = string[pierwsza_spacja..string.length]
				string.slice!(0..pierwsza_spacja)
			end
			koniec = string.to_s =~ /<\/(ins|del)/
			if koniec != nil
				nastepny = string[koniec..-1].index(/<(ins|del)/)
			else
				puts 'error!'
				break
			end
			if nastepny == nil
				out += string[0..koniec+limit]
				szukaj = false
			elsif nastepny > 2*limit #    [0___s####k_ (>2l) _n]
				out += string[0..(koniec + limit)] + '...'
				string.slice!(0..(koniec + nastepny)-limit)
				nastepny = limit
			elsif
				out += string[0..(koniec + nastepny)]
				string.slice!(0..(koniec + nastepny))
				nastepny = 0
			end
		else 
			out = nil
		end
	end
	out
end

def znajdz_roznice(pobrana, pamietana)
	if (md5(pobrana) != md5(pamietana))
		pos_body = pobrana =~ /<body[^>]*>/i
		pobrana.slice!(0..pos_body) if pos_body != nil
		pobrana.gsub!(/(\s){2,}/, " ")
		acceptable_tags = "b|u|i|strong|cite|em"
		# obcięcie tagów
		pamietana.gsub!(/<(\/)?(?!((#{acceptable_tags})(>|\s[^>]+>)))[a-zA-Z][^>]*>/, "")
		pobrana.gsub!(/<(\/)?(?!((#{acceptable_tags})(>|\s[^>]+>)))[a-zA-Z][^>]*>/, "")
		
		Differ.format = :html
		diff = Differ.diff_by_word(pobrana, pamietana)

		start = diff.to_s =~ /<(ins|del)/ 
		if (start != nil) # są różnice
			return skroc(diff.to_s)
		else 
			#out = "Strona się nie zmieniła"
			return nil
		end
	else
		return nil
	end
end

def sprawdz_aktualizacje(adres)
	begin
		pobrana = pobierz(adres)
	rescue
		return "Nie udało się pobrać"
	end
	
	begin
		pamietana = File.open(RAILS_ROOT+'/db/pobrane/'+ md5(adres), 'r').read
	rescue
		zapisz(adres, pobrana)
		return nil  # nie ma kopii na dysku
	end

	roznica = znajdz_roznice(pobrana, pamietana)
	if roznica == nil  # nie ma nic nowego
		return nil
	else
		old_komunikaty = Address.find(md5(adres)).komunikaty
		Address.update(md5(adres), :komunikaty => old_komunikaty + " " + Message.create( :tresc => roznica, :data => Time.now).id.to_s)
		zapisz(adres, pobrana)
		return roznica
	end
end

class RssController < ApplicationController
	def of
		#headers['Content-type'] = 'text/xml'
		@tablica = []
		@out = ''
		user = User.find(params[:id])
		user.obserwowane.split.each { |adres_hash|
			rekord = Address.find(:first, :conditions => "klucz = '#{adres_hash}'") 
				if DateTime.now > (DateTime.parse(rekord.data_spr.to_s) + (1.0 / 24 / 60 / 4) ) and rekord.blokada == false
				rekord.blokada = true
				rekord.save
				roznica = sprawdz_aktualizacje(rekord.adres)
				rekord.blokada = false
				rekord.save
				if roznica != nil
					@out += "Roznica: #{rekord.adres}  #{md5(rekord.adres)}  ***\n" + roznica + "\n\n"
				else 
					@out += "Roznica: #{rekord.adres}  #{md5(rekord.adres)}  ***\n brak roznic \n\n"
				end
			elsif
				@out += "*** #{rekord.adres}  #{md5(rekord.adres)}  ***\n brak roznic bo za wczesnie sprawdzasz \n\n"
			end
			komunikaty = rekord.komunikaty
			if !(komunikaty.nil?) 
				komunikaty.split.each { |komunikat_id|
					komunikat = Message.find(:first, :conditions => "id = '#{komunikat_id}'") 
					@out += "Komunikat: #{komunikat.id} o #{komunikat.data} \n\n"
					opis = rekord.adres
					if(!rekord.opis.nil? and rekord.opis != '')
						opis = rekord.opis
					end 
					@tablica << {:adres => rekord.adres, :opis => opis, :data_mod => komunikat.data.rfc2822, :komunikat => komunikat.tresc}
				}
			end
			
		}
	end
end

