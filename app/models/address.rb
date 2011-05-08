class Address < ActiveRecord::Base
	has_many :messages
	has_many :sites
	has_many :users, :through => :sites
	
	# validates :klucz, :presence => true
	validates :adres, :presence => true #,  :uniqueness =>  { :scope => [:xpath, :css, :regexp] }
	
	def self.get_subscribed(eportal, user)

		agent = Mechanize.new
		agent.get("http://#{eportal}") do |main_page|
			logged = main_page.form_with(:action => "https://#{eportal}/login/index.php") do |f|
				if eportal == 'eportal-ch.pwr.wroc.pl'
					f.username	= user.fire_login
					f.password	= user.fire_password
				end
				
				if eportal == 'eportal-iz.pwr.wroc.pl'
					f.username	= user.air_login
					f.password	= user.air_password
				end
				
				if eportal == 'eportal.pwr.wroc.pl'
					f.username	= user.earth_login
					f.password	= user.earth_password
				end
				
			end.click_button

			verified = false
			Nokogiri::HTML(logged.body).css('.headermenu a').each do |link|
				if link.content == 'Wyloguj'
					verified = true
				end
			end

			if verified
				address_fork = []
			
				agent.get("http://#{eportal}/my/") do |personal_page|
					Nokogiri::HTML(personal_page.body).css('#layout-table a').each do |link|
						if link.content != "Forum aktualności" and link.content != "Aktualności"
							address_fork << {:href => link['href'].clone, :content => link.content.clone }
						end
					end
				end

				return address_fork
			else
				return nil
			end
		end
	end
	
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
		
		# Tylko do obserwowania forum bte.boo.pl
		
		def get_posts(page)
			even_posts = []
			odd_posts = []
	
			parsed = Nokogiri::HTML(page.body)
	
			parsed.css('table.forumline td.row1 .postbody').each do |element|
				even_posts << element.content if not element.content =~ /^_________________/
			end
	
			parsed.css('table.forumline td.row2 .postbody').each do |element|
				odd_posts << element.content if not element.content =~ /^_________________/
			end
	
			return even_posts.zip(odd_posts).flatten
		end

		def get_next(page)
			if not (links = Nokogiri::HTML(page.body).css('.pagination a[title="Dalej"]')).empty?
				"http://bte.boo.pl/#{links.first()['href']}"
			else
				nil
			end
		end
		
		def get_previous(page)
			if not (links = Nokogiri::HTML(page.body).css('.pagination a[title="Wstecz"]')).empty?
				"http://bte.boo.pl/#{links.first()['href']}"
			else
				nil
			end
		end
		
		
		# Pobieranie
		
		logger.info "[#{self.adres}] Rozpoczynam sprawdzanie adresu."
		
		suspend_time = (1.0/24/60) * 0	# minut
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

			if adres =~ /(bte\.boo\.pl\/viewtopic\.php\?(p|t)=[0-9]+)/
				adres = "http://#{$1}"

				agent.get('http://bte.boo.pl/login.php').form_with(:action => /^login.php/) do |form|
					form.username	= 'maciek'
					form.password	= 'pieklo555'
				end.click_button
				
				page = agent.get(adres)
			end

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
				forum_bte = false;
				forum_bte = true if self.adres =~ /(bte\.boo\.pl\/viewtopic\.php\?(p|t)=[0-9]+)/
				
				self.data_mod = Time.now
		
				if first_time and forum_bte
					page = agent.get("#{self.adres}&start=0")
					posts = get_posts(page)

					while (more = get_next(page))
						page = agent.get(more)
						posts.concat(get_posts(page))
					end

					posts = posts.delete_if { |post| post.nil? || post.empty? }
					hash = posts.collect { |post| post.sha }
				end
				
				if !first_time
					if not forum_bte
						message = 'Pod wybranym adresem pojawiły się zmiany.'
						if !binary(page.content_type)
							message = compare(self.last_content, simplified)
						end
						self.messages.create(:tresc => message, :data => Time.now)
					else
						previous = YAML.load(self.last_content)
						previous_hash = previous[:posts_hash]
						
						logger.info "TOPIC.TAIL #{previous[:topic_tail]}"
						
						page = agent.get(previous[:topic_tail])
						posts = get_posts(page)

						while (more = get_next(page))
							page = agent.get(more)
							posts.concat(get_posts(page))
						end

						posts = posts.delete_if { |post| post.nil? || post.empty? }
						hash = posts.collect { |post| post.sha }
						post_map = {}
							
						posts.each do |post|
							post_map[post.sha] = post
						end
						
						new_posts_hash = hash - previous_hash
						
						new_posts_hash.each do |hash|
							self.messages.create(:tresc => post_map[hash], :data => Time.now)
						end
					end
		
					logger.info "[#{self.adres}] Dodano komunikat"
				end
		
				if !binary(page.content_type)
					self.last_content = simplified
					self.last_content = YAML.dump({:topic_tail => agent.page.uri.to_s, :posts_hash => hash}) if forum_bte
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
