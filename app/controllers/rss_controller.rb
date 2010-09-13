require 'active_record'
require 'nokogiri'

# Skrót do liczenia sumy md5
# @param [String] Ciąg znaków z którego będzie liczona suma
# @return [String] suma md5
def md5(var)
	return Digest::MD5.hexdigest(var)
end

# Dopisuje string poprzedzony timestampem do logu w Rails.root.to_s/log/log
# @param [String] Ciąg znaków zawierający komunikat dopisywany do logu
def add_log(tresc)
	File.open("#{Rails.root.to_s}/log/log", "a") do |f|
		f << "#{Time.now.strftime("[%d| %H:%M:%S]")} #{tresc}\n"
	end
end

# Klasa obsługująca pobieranie stron i sprawdzanie aktualizacji
class Strona
# @param [String] String zawierający ciało sprawdzanego dokumentu
	attr_accessor :body
# @param [Address] obiekt ActiveRecord zawierający dane o adresie
	attr_accessor :rekord
# @param [String] String zawierający content_type
	attr_accessor :typ
	
# @param [Address] obiekt ActiveRecord zawierający dane o adresie
	def initialize(rekord)
		@rekord = rekord 
		@body = ""
		@adres = @rekord.adres
		@id = @rekord.id
		sprawdz_aktualizacje
		@rekord.save
	end
	
	# Sprawdza, czy pobrany plik jest "binarny" (nie jest typu html/txt)
	# @return [bool] 
	def binarny?
		return (@typ =~ /html|text/) == nil
	end
	
	# Pobiera plik z podanego adresu, aktualizuje czas w bazie, zapisuje dane do @body, @typ
	def pobierz
		temp = Curl::Easy.perform(@adres)
		@rekord.data_spr = Time.new
		@body = temp.body_str
		@typ = temp.content_type
		add_log "[#{@adres}] Pobrano BODY"
		add_log "[#{@adres}][i] jest binarny \"#{@typ}\"" if binarny?
	end
	
	# Zapisuje @body do pliku @id
	def zapisz
		File.open("#{Rails.root.to_s}/db/pobrane/#{@id}", "w") do |f|
			f << @body
		end
		add_log "Zapisano #{@adres} jako #{@id}"
	end

	# Sprawdza aktualizacje z podanym opóźnieniem
	def sprawdz_aktualizacje
		opoznienie = (1.0 / 24 / 60 * 15) *0 # 15 min
		add_log "[#{@adres}] Rozpoczynam sprawdzanie"
		if DateTime.now > (DateTime.parse(@rekord.data_spr.to_s) + opoznienie ) 
			if !@rekord.blokada
				Address.update(@rekord.id, :blokada => true)
				begin
					pobierz 
				rescue
					add_log "[#{@adres}][!!] Nie udało się pobrać adresu"
					Address.update(@rekord.id, :blokada => false)
				else
					begin
						pamietana = File.open("#{Rails.root.to_s}/db/pobrane/#{@id}", 'r').read
					rescue
						okroj
						zapisz
						Address.update(@rekord.id, :blokada => false)
					else
						roznica = porownaj_z(pamietana)
						if roznica == nil	# nie ma nic nowego
							add_log "[#{@adres}] Nie znaleziono roznic"
						else
							add_log "[#{@adres}] Znaleziono roznice"
							@rekord.messages.create(:tresc => roznica, :data => Time.now)
							@rekord.data_mod = Time.now
							add_log "[#{@adres}] Dodano komunikat"
							zapisz
						end
						Address.update(@rekord.id, :blokada => false)
					end
				end
			else
				add_log "[#{@adres}][!!] ZABLOKOWANY!"
			end
		else
			add_log "[#{@adres}][i] Za szybko sprawdzano ponownie."
		end
	end

	# Obcina z @body niepotrzebne spacje, korzysta z regexpa, xpatha, css, skraca do pierwszego wystąpienia body, usuwa <script> a później tagi HTML
	def okroj
		@body.gsub!(/\s+/, " ")
		if @rekord.regexp != ""
			add_log "[#{@adres}][i] Sprawdzanie regexpa."
			@body = @body.scan(@rekord.regexp).join(" ... ")
		end
		if @rekord.xpath != ""
			add_log "[#{@adres}][i] Sprawdzanie xpatha."
			@body = Nokogiri::HTML(@body).xpath(@rekord.xpath).text
		end
		if @rekord.css != ""
			add_log "[#{@adres}][i] Sprawdzanie css"
			@body = Nokogiri::HTML(@body).css(@rekord.css).text
		end
		body_index = @body.index(/<[Bb][Oo][dD][Yy].*/m)
		@body.slice!(0..body_index) if body_index != nil
		@body.gsub!(/<script[^>]*>.*<\/script>/, "")
#			pamietana.gsub!(/<(.|\n)*?>/, "")
		@body.gsub!(/<(.|\n)*?>/, "")
	end
	
	# Porównuje zawartość @body z podanym stringiem
	# @param [String] String z którym porównywane będzie @body
	# @return [String,nil] różnica między @body a stringiem
	def porownaj_z(pamietana)
		if binarny?
			if (md5(@body) != md5(pamietana))
				return "Pojawiły się zmiany w pliku"
			end
		else
			okroj
			zapisz_tymczasowo(@body,@id)
			diff = os_wdiff(@id)
			start = diff.to_s =~ /<(ins|del)>/ 
			if (start != nil) # są różnice
				return skroc(diff.to_s)
			else 
				#Strona się nie zmieniła
				return nil
			end
		end
	end
end # Strona.class

#def pobierz(adres)
#	Address.update(md5(adres), :data_spr => Time.new )
#	return Curl::Easy.perform(adres).body_str
#end

# Funkcja skraca output diffa (obcina przerwy między <del>/<ins> dłuższe niż 50 znaków) 
# @param [String] String do skrócenia
# @return [String] Skrócony string 
def skroc(string)
	out 			= ""
	limit 		= 50
	szukaj 		= true
	nastepny 	= nil

	while szukaj
		if nastepny == nil
			start = string.to_s.index(/<(ins|del)/)
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
			koniec = string.to_s.index(/<\/(ins|del)/)
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

# Funkcja zapisuje w /db/pobrane/ plik tymczasowy (wykorzystywane do zapisania @body przy porównywaniu diffem z pamiętaną stroną)
# @param [String] Treść pliku temp
# @param [String] Nazwa pliku (zostanie dodane do niej _tmp)
def zapisz_tymczasowo(tresc, jako)
	File.open("#{Rails.root.to_s}/db/pobrane/#{jako}_temp", "w") do |f|
		f << tresc
	end
	add_log "Zapisano plik tymczasowy : #{jako}_temp"
end

# Usuwanie pliku
# @param [String] nazwa pliku
def usun_temp(file)
	if File.exist?(file)
		File.delete(file)
	else
		add_log "Blad przy usuwaniu: #{plik}"
	end
end

# Funkcja wywołuje polecenie systemowe diff. Wykorzystuje podany parametr by wiedzieć jakie pliki porównać (<nazwa> i <nazwa>_tmp). Tworzy tymczasowo plik <nazwa>_diff, po czym usuwa go, wraz z <nazwa>_tmp
# @param [String] nazwa pliku
# @return [String] Różnica między plikami ubrana w HTML
def os_wdiff(md5key)
	temp = "#{Rails.root.to_s}/db/pobrane/#{md5key}_temp"
	pamietane = "#{Rails.root.to_s}/db/pobrane/#{md5key}"
	diff_file = "#{Rails.root.to_s}/db/pobrane/#{md5key}_diff"
	system	"wdiff --start-delete=\"<del>\" --end-delete=\"</del>\" --start-insert=\"<ins>\" --end-insert=\"</ins>\" #{pamietane} #{temp} >> #{diff_file}"
	f_diff = File.open(diff_file, 'r')	 
	tresc_diff = f_diff.read	 
	f_diff.close	
	usun_temp(diff_file)
	usun_temp(temp)
	return tresc_diff
end

# Funkcja tworzy tablicę komunikatów RSS dla użytkownika
# @param [User] ActiveRecord zawierający dane o użytkowniku
# @return [Array] Tablica komunikatów rss
def generuj_zawartosc_rss(user)
	rss = []
	user.obserwowane.split.each { |id_adresu|
		strona_w_db = Address.find(id_adresu) 
		polecenie_aktualizacji = Strona.new(strona_w_db)
		komunikaty = strona_w_db.messages
		if komunikaty != []
			komunikaty.each { |komunikat|
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
	skip_before_filter :require_admin_login, :only => [:web, :of]
	skip_before_filter :require_login, :only => [:of]
	def of
		headers['Content-type'] = 'text/xml'
		@tablica = generuj_zawartosc_rss(User.where({:klucz => params[:id]}).first).sort! { |a,b| a[:data_mod] <=> b[:data_mod] }
		render :layout => false
	end
	
	def web
		@tablica = generuj_zawartosc_rss(current_user).sort! { |a,b| Time.parse(b[:data_mod]) <=> Time.parse(a[:data_mod]) }
	end
	
	def test
#		if session[:dupa] == 'kot'
#		redirect_to 'public/404.html'
	end
end

