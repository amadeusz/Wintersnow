require 'active_record'

def md5(var)
	return Digest::MD5.hexdigest(var)
end

def add_log(tresc)
	File.open(RAILS_ROOT+'/log/log', "a") do |f|
		f << Time.now.strftime("[%d| %H:%M:%S] ")+tresc+"\n"
	end
end

class Strona
  attr_accessor :adres,:body
  def initialize(adres)
    @adres = adres
    @md5key = md5(adres)
    sprawdz_aktualizacje
  end
  
  def pobierz
		Address.update(@md5key, :data_spr => Time.new )
		@body = Curl::Easy.perform(@adres).body_str
		add_log "Pobrano BODY #{@adres}"
	end
	
	def zapisz
		File.open(RAILS_ROOT+'/db/pobrane/'+ @md5key, "w") do |f|
			f << @body
		end
		add_log "Zapisano #{@adres} jako #{@md5key}"
	end

	def sprawdz_aktualizacje
		opoznienie = (1.0 / 24 / 60 * 15) *0# 15 min
		add_log "[*] Rozpoczynam sprawdzanie adresu #{@adres}"
		rekord = Address.find(:first, :conditions => "klucz = '#{@md5key}'") 
		if DateTime.now > (DateTime.parse(rekord.data_spr.to_s) + opoznienie ) 
			if rekord.blokada == false
			#if true
				Address.update(@md5key, :blokada => true)
				begin
					pobierz 
				rescue
					add_log "!!!! Nie udało się pobrać adresu #{@adres}"
					Address.update(@md5key, :blokada => false)
					return
				end

				begin
					pamietana = File.open(RAILS_ROOT+'/db/pobrane/'+ @md5key, 'r').read
				rescue
					zapisz
					Address.update(@md5key, :blokada => false)
					return nil  # nie ma kopii na dysku
				end
				jest_rozna, roznica = znajdz_roznice(@body, pamietana)
				if jest_rozna == false  # nie ma nic nowego
					add_log "Nie znaleziono roznic w #{@adres} "
				else
					add_log "Znaleziono roznice w #{@adres} "
					old_komunikaty = Address.find(@md5key).komunikaty
					Address.update(@md5key, :komunikaty => old_komunikaty + " " + Message.create( :tresc => roznica, :data => Time.now).id.to_s, :data_mod  => Time.now)
					add_log "Dodano komunikat związany z #{@adres} "
					zapisz
				end
				Address.update(@md5key, :blokada => false)
			else
				add_log "#{@adres} jest ZABLOKOWANY!"
			end
		else
			add_log "Za szybko sprawdzano #{@adres} !"
		end
	end
end

#def pobierz(adres)
#	Address.update(md5(adres), :data_spr => Time.new )
#	return Curl::Easy.perform(adres).body_str
#end

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
				add_log 'error!'
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
		pos_body = pobrana =~ /\<[bB][oO][dD][yY][^>]*\>/i
		pobrana.slice!(0..pos_body-1) if pos_body != nil
		pobrana.gsub!(/(\s){2,}/, " ")
		pobrana.gsub!(/<script[^>]*>.*<\/script>/, "")
		acceptable_tags = "b|u|i|strong|cite|em"
		# obcięcie tagów
		pamietana.gsub!(/<(\/)?(?!((#{acceptable_tags})(>|\s[^>]+>)))[a-zA-Z][^>]*>/, "")
		pobrana.gsub!(/<(\/)?(?!((#{acceptable_tags})(>|\s[^>]+>)))[a-zA-Z][^>]*>/, "")
		zapisz_tymczasowo(pobrana,@md5key)

		diff = os_wdiff(@md5key)

		start = diff.to_s =~ /<(ins|del)>/ 
		if (start != nil) # są różnice
			return true, skroc(diff.to_s)
		else 
			#out = "Strona się nie zmieniła"
			return false, nil
		end
	else
		return nil,nil
	end
end

def zapisz_tymczasowo(tresc, jako)
	File.open(RAILS_ROOT+'/db/pobrane/'+ jako +"_temp", "w") do |f|
		f << tresc
	end
	add_log "Zapisano plik tymczasowy : #{jako}_temp"
end

def usun_temp(file)
	if File.exist?(file)
		File.delete(file)
	else
		add_log "Blad przy usuwaniu: #{plik}"
	end
end

def os_wdiff(md5key)
	temp = RAILS_ROOT+'/db/pobrane/'+ md5key + "_temp"
	pamietane = RAILS_ROOT+'/db/pobrane/'+ md5key
	diff_file = RAILS_ROOT+'/db/pobrane/'+ md5key + "_diff"
	system  "wdiff --start-delete=\"<del>\" --end-delete=\"</del>\" --start-insert=\"<ins>\" --end-insert=\"</ins>\" #{pamietane} #{temp} >> #{diff_file}"
	f_diff = File.open(diff_file, 'r')   
	tresc_diff = f_diff.read   
	f_diff.close  
	usun_temp(diff_file)
	usun_temp(temp)
	return tresc_diff
end

def generuj_zawartosc_rss(user)
	tablica = []
	user.obserwowane.split.each { |adres_hash|
		rekord = Address.find(:first, :conditions => "klucz = '#{adres_hash}'") 
			cos = Strona.new(rekord.adres)
#				roznica = sprawdz_aktualizacje()
#				rekord.blokada = false
#				rekord.save
#				if roznica != nil
#					@out += "Roznica: #{rekord.adres}  #{md5(rekord.adres)}  ***\n" + roznica + "\n\n"
#				else 
#					@out += "Roznica: #{rekord.adres}  #{md5(rekord.adres)}  ***\n brak roznic \n\n"
#				end
#			elsif
#				@out += "*** #{rekord.adres}  #{md5(rekord.adres)}  ***\n brak roznic bo za wczesnie sprawdzasz \n\n"
#			end
		komunikaty = rekord.komunikaty
		if !(komunikaty.nil?) 
			komunikaty.split.each { |komunikat_id|
				komunikat = Message.find(:first, :conditions => "id = '#{komunikat_id}'") 
				opis = rekord.adres
				if(!rekord.opis.nil? and rekord.opis != '')
					opis = rekord.opis
				end 
				tablica << {:id => komunikat.id, :adres => rekord.adres, :opis => opis, :data_mod => komunikat.data.rfc2822, :komunikat => komunikat.tresc}
			}
		end
	}
	return tablica
end

class RssController < ApplicationController
	def of
		headers['Content-type'] = 'text/xml'
		tablica = []
		out = ''
		user.obserwowane.split.each { |adres_hash|
			rekord = Address.find(:first, :conditions => "klucz = '#{adres_hash}'") 
				cos = Strona.new(rekord.adres)
#				roznica = sprawdz_aktualizacje()
#				rekord.blokada = false
#				rekord.save
#				if roznica != nil
#					@out += "Roznica: #{rekord.adres}  #{md5(rekord.adres)}  ***\n" + roznica + "\n\n"
#				else 
#					@out += "Roznica: #{rekord.adres}  #{md5(rekord.adres)}  ***\n brak roznic \n\n"
#				end
#			elsif
#				@out += "*** #{rekord.adres}  #{md5(rekord.adres)}  ***\n brak roznic bo za wczesnie sprawdzasz \n\n"
#			end
			komunikaty = rekord.komunikaty
			if !(komunikaty.nil?) 
				komunikaty.split.each { |komunikat_id|
					komunikat = Message.find(:first, :conditions => "id = '#{komunikat_id}'") 
					out += "Komunikat: #{komunikat.id} o #{komunikat.data} \n\n"
					opis = rekord.adres
					if(!rekord.opis.nil? and rekord.opis != '')
						opis = rekord.opis
					end 
					tablica << {:adres => rekord.adres, :opis => opis, :data_mod => komunikat.data.rfc2822, :komunikat => komunikat.tresc}
				}
			end
		}
	end
	def test
			@tablica = generuj_zawartosc_rss(User.find(params[:id])).sort! { |a,b| a[:data_mod] <=> b[:data_mod] }


	end
end

