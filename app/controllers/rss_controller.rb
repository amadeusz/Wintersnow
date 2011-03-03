require 'active_record'
require 'nokogiri'
require 'mechanize'

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
		agent = Mechanize.new
		
		# paskudny hack na IZ
		if not (@adres =~ /eportal\.ii\.pwr\.wroc\.pl\/w08\/board/).nil? 
			agent.basic_auth(current_user.water_login, current_user.water_password)
		end

		temp = agent.get(@adres)
		
		if adres.include? 'eportal-ch.pwr.wroc.pl'
			temp = temp.form_with(:action => 'https://eportal-ch.pwr.wroc.pl/login/index.php') do |f|
				f.username = current_user.fire_login
				f.password = current_user.fire_password
			end.click_button
		end
		
		if adres.include? 'eportal-iz.pwr.wroc.pl'
			temp = temp.form_with(:action => 'https://eportal-iz.pwr.wroc.pl/login/index.php') do |f|
				f.username = current_user.air_login
				f.password = current_user.air_password
			end.click_button
		end
		
		if adres.include? 'eportal.pwr.wroc.pl'
			temp = temp.form_with(:action => 'https://eportal.pwr.wroc.pl/login/index.php') do |f|
				f.username = current_user.earth_login
				f.password = current_user.earth_password
			end.click_button
		end
		
		@rekord.data_spr = Time.new
		@body = temp.body
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
		opoznienie = (1.0 / 24 / 60)   * 0 # minut
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
						Dir.mkdir('#{Rails.root.to_s}/db/pobrane') if not File.directory? '#{Rails.root.to_s}/db/pobrane'
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
		
		#body_index = @body.index(/<[bB][oO][dD][yY].*/m) -1
		
		parsed = Nokogiri::HTML(@body)
		
		parsed.search('//script').each do |node|
			node.remove
		end
		
		parsed.search('//style').each do |node|
			node.remove
		end
		
		@body = parsed.text

		@body = Nokogiri::HTML(@body).xpath("//text()").to_s
		
#		@body.slice!(0..body_index) if body_index != nil
#		@body.gsub!(/<script[^>]*>.*<\/script>/, "")
##			pamietana.gsub!(/<(.|\n)*?>/, "")
#		@body.gsub!(/<(.|\n)*?>/, "")
	end
	
	# Porównuje zawartość @body z podanym stringiem
	# @param [String] String z którym porównywane będzie @body
	# @return [String,nil] różnica między @body a stringiem
	def porownaj_z(pamietana)
		if binarny?
			if (@body.md5 != pamietana.md5)
				return "Pojawiły się zmiany w pliku"
			end
		else
			okroj
			zapisz_tymczasowo(@body,@id)
			diff = os_wdiff(@id)
			pozycja_startowa = diff =~ /<(ins|del)/ 
			if (pozycja_startowa != nil) # są różnice
				return skroc(diff)
			else 
				#Strona się nie zmieniła
				return nil
			end
		end
	end
end

# Funkcja skraca output diffa (obcina przerwy między <del>/<ins> dłuższe niż 50 znaków) 
# @param [String] String do skrócenia
# @return [String] Skrócony string 
def skroc(s)
#	string = s
#	out 			= ""
#	limit 		= 50
#	szukaj 		= true
#	nastepny_tag_zmiany 	= nil
#	
#	while szukaj
#		if nastepny_tag_zmiany == nil
#			pozycja_startowa = string.index(/<(ins|del)>/)
#		else 
#			pozycja_startowa = nastepny_tag_zmiany 
#		end
#		# koniec = string.to_s =~ /<\/(ins|del)/
#		if pozycja_startowa != nil
#			pierwsza_spacja = string.index(/ /)
#			until pozycja_startowa < limit or pierwsza_spacja == nil 
#				pierwsza_spacja = string[0..pozycja_startowa-1].index(/ /)
#				if !pierwsza_spacja.nil?
#					string.slice!(0..pierwsza_spacja)
#					string = "..." + string 
#					pozycja_startowa = string.index(/<(ins|del)>/)
#				end
#			end
#			out += "<div>"
#			pozycja_startowa = string.index(/<(ins|del)>/) 			# to nie jest chyba potrzebne
#			pozycja_koncowa = string.index(/<\/(ins|del)>/)
#			if pozycja_koncowa != nil
#				pozycja_koncowa += 6 # trzeba sie przesunąć za </ins>
#				nastepny_tag_zmiany = string[pozycja_koncowa..-1].index(/<(ins|del)>/)
#			else
#				puts "add_log 'error!'"
#				break
#			end
#			if nastepny_tag_zmiany == nil
#				out += string[0..pozycja_koncowa+limit]
#				szukaj = false
#			elsif nastepny_tag_zmiany > 2*limit #		[0___s####k_ (>2l) _n]
#				out += (string[0..(pozycja_koncowa + limit)] + '...')
#				string.slice!(0..(pozycja_koncowa + nastepny_tag_zmiany-1)-limit)
#				nastepny_tag_zmiany = limit
#			elsif
#				out += string[0..(pozycja_koncowa + nastepny_tag_zmiany-1)]
#				string.slice!(0..(pozycja_koncowa + nastepny_tag_zmiany-1))
#				nastepny_tag_zmiany = 0
#			end
#			out += "</div>"
#		else 
#			szukaj = false
#			out = nil
#		end
	string 		= s
	limit 		= 50
	zmiana		= []
	pointer 	= 0
	while pozycja = string.index(/<(ins|del)>/)
		typ = $1
		koniec = string.index(/<\/#{$1}>/)
		#puts "# " + string[pozycja..koniec+5]
		zmiana += [{:typ => typ, :start => pozycja+pointer, :koniec => koniec+5+pointer}]
		pointer += koniec+6
		string = string[koniec+6..string.length]
		#puts string
	end

	i = 0
	out = ""
	liczba_zmian = zmiana.length
	while i < liczba_zmian
		out += "<div>\n"
		out += "..." if zmiana[i][:start]-25 > 0
		if zmiana[i][:start] > limit/2
			from = zmiana[i][:start]-limit/2
		else 
			from = 0
		end
		to = zmiana[i][:koniec]
		
		add_log zmiana[i].inspect
		add_log "from: #{from} to: #{to}"
		add_log s[from..to]
		
		out += ""+s[from..to]
		if i+1 < zmiana.length and (zmiana[i+1][:start] - zmiana[i][:koniec]) < limit   
			out += s[zmiana[i][:koniec]+1..zmiana[i+1][:koniec]]
			i += 1
		end
		out += s[zmiana[i][:koniec]+1..zmiana[i][:koniec]+25]
		out += "..." if zmiana[i][:koniec]+25 < s.length
		out += "\n</div>\n"
		i += 1
	end
	if not out.nil?
		out.gsub!(/<del>/, '<del color="#CE4641">') 
		out.gsub!(/<ins>/, '<ins color="#1C8522">') 
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
def sprawdz_zawartosc_rss(user)
	user.addresses.each { |strona_w_db|
		polecenie_aktualizacji = Strona.new(strona_w_db)
	} if not user.addresses.empty? 
end

class RssController < ApplicationController
	skip_before_filter :require_admin_login, :only => [:web, :of, :update]
	skip_before_filter :require_login, :only => [:of]
	
	def of
		headers['Content-type'] = 'text/xml'
		sprawdz_zawartosc_rss(User.find_by_klucz(params[:id]))
		render :layout => false
	end
	
	def update
		sprawdz_zawartosc_rss(current_user)
		respond_to do |format|
			format.html { render :layout => false }
			format.xml	{ head :ok }
		end
	end
	
	def web
		respond_to do |format|
			format.html
			format.xml	{ head :ok }
		end
	end
	
end

