class Address < ActiveRecord::Base
	has_many :messages
	has_many :sites
	has_many :users, :through => :sites
	
	# validates :klucz, :presence => true
	validates :adres, :presence => true #,  :uniqueness =>  { :scope => [:xpath, :css, :regexp] }
	
	def look_for_changes
		
		def simplify(html)
			html.gsub!(/\s+/, " ")
		
			if regexp != ""
				logger.info "[#{self}][i] Wykonywanie regexpa."
				html = html.scan(regexp).join(" ... ")
			end
		
			if xpath != ""
				logger.info "[#{self}][i] Wykonywanie xpatha."
				html = Nokogiri::HTML(html).xpath(xpath).text
			end
		
			if css != ""
				logger.info "[#{self}][i] Wykonywanie css"
				html = Nokogiri::HTML(html).css(css).text
			end
	
			parsed = Nokogiri::HTML(html)
			parsed.search('//script').each { |node| node.remove }
			parsed.search('//style').each { |node| node.remove }
			Nokogiri::HTML(parsed.text).xpath("//text()").to_s
		end
		
		def binary(type)
			return (type =~ /html|text/) == nil
		end
		
		def compare(str1, str2)
		
			def splice(s)
				string 		= s
				limit 		= 50
				zmiana		= []
				pointer 	= 0
				while pozycja = string.index(/<(ins|del)>/)
					typ = $1
					koniec = string.index(/<\/#{$1}>/)
					zmiana += [{:typ => typ, :start => pozycja+pointer, :koniec => koniec+5+pointer}]
					pointer += koniec + 6
					string = string[koniec + 6..string.length]
				end

				i = 0
				out = ""
				liczba_zmian = zmiana.length
				while i < liczba_zmian
					out += "<div>\n"
					out += "..." if (zmiana[i][:start] -25) > 0
					if zmiana[i][:start] > limit/2
						from = zmiana[i][:start] -limit/2
					else 
						from = 0
					end
					to = zmiana[i][:koniec]
		
					logger.info "#{zmiana[i].inspect} from: #{from} to: #{to} #{s[from..to]}"
		
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
#				if not out.nil?
#					out.gsub!(/<del>/, '<del color="#CE4641">') 
#					out.gsub!(/<ins>/, '<ins color="#1C8522">') 
#				end
				out
			end

			splice(Wdiff::Helper.to_html(str1.wdiff(str2)))
		end
		
		
		# Pobierz
		
		logger.info "[#{self.adres}] Rozpoczynam sprawdzanie adresu."
		
		suspend_time = (1.0/24/60) * 28	# minut
		if self.data_spr && DateTime.now < (DateTime.parse(self.data_spr.to_s) + suspend_time)
			logger.info "[#{self.adres}] Niedawno sprawdzałem, pomijam."
			return
		end
		
		if self.blokada
			logger.info "[#{self.adres}] Adres oznaczony jako zablokowany, pomijam."
			return
		end
		
		
		# Spróbuj pobrać
	
		# Wstępne założenie blokady, na wypadek niskopoziomowej awarii skryptu
		self.blokada = true; save
			
		begin
		
			agent = Mechanize.new

			if self.one_user
				def current_user
					self.users.first
				end
			end

			if self.one_user
				if adres =~ /eportal\.ii\.pwr\.wroc\.pl\/w08\/board/
					agent.basic_auth(current_user.water_login, current_user.water_password)
				end
			end

			page = agent.get(adres)


			# Obsługa niektórych stron

			if self.one_user
				if adres.include? 'eportal-ch.pwr.wroc.pl'
			
					login = page.form_with(:action => 'https://eportal-ch.pwr.wroc.pl/login/index.php') do |form|
						if (form)
							form.username = current_user.fire_login
							form.password = current_user.fire_password
						end
					end

					page = login.click_button if login
	
				elsif adres.include? 'eportal-iz.pwr.wroc.pl'

					login = page.form_with(:action => 'https://eportal-iz.pwr.wroc.pl/login/index.php') do |form|
						if (form)
							form.username = current_user.air_login
							form.password = current_user.air_password
						end
					end

					page = login.click_button if login
	
				elsif adres.include? 'eportal.pwr.wroc.pl'

					login = page.form_with(:action => 'https://eportal.pwr.wroc.pl/login/index.php') do |form|
						if (form)
							form.username = current_user.earth_login
							form.password = current_user.earth_password
						end
					end
	
				end
			end

		rescue Exception => e
			logger.info "[#{self.adres}] Nie udało się pobrać pliku, #{e.message}."
			
		else
		
			# Po pomyślnym pobraniu
			
			self.data_spr = Time.new
			first_time = self.last_content_checksum.nil?
			
			content_changed = false
			
			simplified = simplify(page.body) if !binary(page.content_type)
		
			if !first_time
				# Porównanie typu plików
				if page.content_type != self.last_content_type
					content_changed = true 
		
				# Porównanie plików binarnych
				elsif binary(page.content_type) && page.body.sha != self.last_content_checksum
					content_changed = true

				# Porównanie plików tekstowych
				elsif !binary(page.content_type) && simplified.sha != self.last_content_checksum
					content_changed = true
				end
			end
		
			if !content_changed && !first_time
				logger.info "[#{self.adres}] Nie znaleziono różnic."
			else
				self.data_mod = Time.now
			
				if !first_time
					message = 'Pod wybranym adresem pojawiły się zmiany.'
					if !binary(page.content_type)
						logger.info self.last_content
						logger.info simplified
						message = compare(self.last_content, simplified)
					end
			
					self.messages.create(:tresc => message, :data => Time.now)
					logger.info "[#{self.adres}] Dodano komunikat"
				end
			
				if !binary(page.content_type)
					self.last_content = simplified
					self.last_content_checksum = simplified.sha
				else
					self.last_content = ''
					self.last_content_checksum = page.body.sha
				end
			
				self.last_content_type = page.content_type
			end
		
			self.blokada = false; save

			logger.info "[#{self.adres}] Pobrano plik typu #{self.last_content_type}"

		end
	end
end
