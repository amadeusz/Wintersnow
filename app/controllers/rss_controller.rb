require 'active_record'
require 'nokogiri'


def md5(var)
	return Digest::MD5.hexdigest(var)
end

def add_log(tresc)
	File.open("#{RAILS_ROOT}/log/log", "a") do |f|
		f << "#{Time.now.strftime("[%d| %H:%M:%S]")} #{tresc}\n"
	end
end

class Strona
	attr_accessor :adres,:body,:typ
	def initialize(adres)
		@adres = adres
		@md5key = md5(adres)
		@rekord = Address.where({:klucz => @md5key}).first
		sprawdz_aktualizacje
		@rekord.save
	end
	
	def binarny?
		return (@typ =~ /html|text/) == nil
	end
	
	def pobierz
		temp = Curl::Easy.perform(@adres)
		@rekord.data_spr = Time.new 
		@body = temp.body_str
		@typ = temp.content_type
		add_log "[#{@adres}] Pobrano BODY"
		add_log "[#{@adres}][i] jest binarny \"#{@typ}\"" if binarny?
	end
	
	def zapisz
		File.open("#{RAILS_ROOT}/db/pobrane/#{@md5key}", "w") do |f|
			f << @body
		end
		add_log "Zapisano #{@adres} jako #{@md5key}"
	end

	def sprawdz_aktualizacje
		opoznienie = (1.0 / 24 / 60 * 15) *0 # 15 min
		add_log "[#{@adres}] Rozpoczynam sprawdzanie"
		if DateTime.now > (DateTime.parse(@rekord.data_spr.to_s) + opoznienie ) 
			if @rekord.blokada == false
				Address.update(@rekord.id, :blokada => true)
				begin
					pobierz 
				rescue
					add_log "[#{@adres}][!!] Nie udało się pobrać adresu"
					Address.update(@rekord.id, :blokada => false)
					return
				end

				begin
					pamietana = File.open("#{RAILS_ROOT}/db/pobrane/#{@md5key}", 'r').read
				rescue
					zapisz
					Address.update(@rekord.id, :blokada => false)
					return nil	# nie ma kopii na dysku
				end
				roznica = porownaj_z(pamietana)
				if roznica != nil	# nie ma nic nowego
					add_log "[#{@adres}] Nie znaleziono roznic"
				else
					add_log "[#{@adres}] Znaleziono roznice"
					@rekord.messages.create(:tresc => roznica, :data => Time.now)
					@rekord.data_mod = Time.now
					add_log "[#{@adres}] Dodano komunikat"
					zapisz
				end
				Address.update(@rekord.id, :blokada => false)
			else
				add_log "[#{@adres}][!!] ZABLOKOWANY!"
			end
		else
			add_log "[#{@adres}][i] Za szybko sprawdzano ponownie."
		end
	end

	def porownaj_z(pamietana)
		if binarny?
			if (md5(@body) != md5(pamietana))
				return "Pojawiły się zmiany w pliku"
			end
		else
			@body.gsub!(/(\s){2,}/, " ")
			if @rekord.regexp != ""
				@body = @body.scan(@rekord.regexp).join(" ... ")
			end
			if @rekord.xpath != ""
				@body = Nokogiri::HTML(@body).xpath(@rekord.xpath).text
			end
			if @rekord.css != ""
				@body = Nokogiri::HTML(@body).css(@rekord.css).text
			end
			body_index = @body.index(/<[Bb][Oo][dD][Yy].*/m)
			@body.slice!(0..pos_body) if pos_body != []
			@body.gsub!(/<script[^>]*>.*<\/script>/, "")
#			pamietana.gsub!(/<(.|\n)*?>/, "")
			@body.gsub!(/<(.|\n)*?>/, "")
			zapisz_tymczasowo(@body,@md5key)

			diff = os_wdiff(@md5key)

			start = diff.to_s =~ /<(ins|del)>/ 
			if (start != nil) # są różnice
				return skroc(diff.to_s)
			else 
				#out = "Strona się nie zmieniła"
				return nil
			end
		end
	end
end # Strona.class

#def pobierz(adres)
#	Address.update(md5(adres), :data_spr => Time.new )
#	return Curl::Easy.perform(adres).body_str
#end

def skroc(string)
	out 			= ""
	limit 		= 50
	szukaj 		= true
	nastepny 	= nil

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
			elsif nastepny > 2*limit #		[0___s####k_ (>2l) _n]
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


def zapisz_tymczasowo(tresc, jako)
	File.open("#{RAILS_ROOT}/db/pobrane/#{jako}_temp", "w") do |f|
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
	temp = "#{RAILS_ROOT}/db/pobrane/#{md5key}_temp"
	pamietane = "#{RAILS_ROOT}/db/pobrane/#{md5key}"
	diff_file = "#{RAILS_ROOT}/db/pobrane/#{md5key}_diff"
	system	"wdiff --start-delete=\"<del>\" --end-delete=\"</del>\" --start-insert=\"<ins>\" --end-insert=\"</ins>\" #{pamietane} #{temp} >> #{diff_file}"
	f_diff = File.open(diff_file, 'r')	 
	tresc_diff = f_diff.read	 
	f_diff.close	
	usun_temp(diff_file)
	usun_temp(temp)
	return tresc_diff
end

def generuj_zawartosc_rss(user)
	rss = []
	user.obserwowane.split.each { |adres_hash|
		strona_w_db = Address.find(:first, :conditions => "klucz = '#{adres_hash}'") 
		polecenie_aktualizacji = Strona.new strona_w_db.adres
		komunikaty = strona_w_db.komunikaty
		if komunikaty.nil? == false
			komunikaty.split.each { |komunikat_id|
				komunikat = Message.find(:first, :conditions => "id = '#{komunikat_id}'") 
				if ( strona_w_db.opis.nil? == false and strona_w_db.opis != '')
					opis = strona_w_db.opis
				else
					opis = strona_w_db.adres
				end 
				rss << {:id => komunikat.id, :adres => strona_w_db.adres, :opis => opis, :data_mod => komunikat.data.rfc2822, :komunikat => komunikat.tresc}
			}
		end
	}
	return rss
end

class RssController < ApplicationController
	def of
		headers['Content-type'] = 'text/xml'
		@tablica = generuj_zawartosc_rss(User.where({:klucz => params[:id]}).first).sort! { |a,b| a[:data_mod] <=> b[:data_mod] }
		render :layout => false
	end
	
	def web
		@tablica = generuj_zawartosc_rss(User.where({:klucz => params[:id]}).first).sort! { |a,b| Time.parse(b[:data_mod]) <=> Time.parse(a[:data_mod]) }
	end
	
	def test
#		if session[:dupa] == 'kot'
#		redirect_to 'public/404.html'
	end
end

