def popraw_usera(params)
	
	if (params[:adres] =~ /^http(s)?:\/\//) == nil
		params[:adres] = "http#{$1}://" + params[:adres]
	end
	
	if params[:adres] =~ /aleph\.bg\.pwr\.wroc\.pl\/F\/([^?]*)/
		params[:adres].gsub! $1, ''
	end
	
	if params[:adres] =~ /(bte\.boo\.pl\/viewtopic\.php\?(p|t)=[0-9]+)/

		def get_topic(page)
			topic = Nokogiri::HTML(page.body).css('.forumline .catHead a.nav').first
			return topic['href']
		end

		agent = Mechanize.new

		params[:adres] = "http://#{$1}"

		agent.get('http://bte.boo.pl/login.php').form_with(:action => /^login.php/) do |form|
			form.username	= 'maciek'
			form.password	= 'pieklo555'
		end.click_button

		if params[:adres] =~ /(bte\.boo\.pl\/viewtopic\.php\?p=[0-9]+)/
			params[:adres] = "http://bte.boo.pl/#{get_topic(agent.get(params[:adres]))}"
		end

		if params[:adres] =~ /(bte\.boo\.pl\/viewtopic\.php\?t=[0-9]+)/
			params[:adres] = "http://#{$1}"
		end
		
	end
	
	return params
end

class AddressesController < ApplicationController
	skip_before_filter :require_admin_login, :only => [:new, :create]

	def unlock
		Address.where(:blokada => true).each do |address| 
			address.blokada = false; address.save
		end
		redirect_to(addresses_path, :notice => 'Zdjęto wszystkie blokady.')
	end

	def index
		@addresses = Address.order("opis ASC")

		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @addresses }
		end
	end
	
	def show
		@address = Address.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml	{ render :xml => @address }
		end
	end

	def new
		@address = Address.new
		
		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @address }
		end
	end

	def edit
		@address = Address.find(params[:id])
	end
	
	def create
		eportal = false
		przekierowanie = ustawienia_path
		success = 0; failed = 0; message = '';
		addresses_pending = []
	
		if params[:address][:adres] != ''
		
			params[:address] = popraw_usera(params[:address])
			params[:address][:opis] ||= ""

			if eportal = (params[:address][:adres] =~ /^http:\/\/(eportal(-iz|-ch)?.pwr.wroc.pl)(\/|\/index.php)?$/)
				subscribed = Address.get_subscribed($1, current_user)
				
				params[:address][:css] = '#middle-column'
				params[:address][:one_user] = true
				params[:address][:private] = true
				
				if subscribed
					new_params = Marshal.load(Marshal.dump(params.dup()))
					description = params[:address][:opis]
					description = 'ePortal' if description == ''
					subscribed.each do |address|
						new_params[:address][:adres] = address[:href]
						new_params[:address][:opis] = "#{description} : #{address[:content]}"
						addresses_pending << new_params.dup()
					end	
				end
				
			else
				if params[:address][:adres] =~ /(portal|wa|wbliw|wch|weka|weny|wggg|wis|wiz|wme|wm|wppt|wemif)\.pwr\.wroc\.pl/ and params[:address][:xpath] == '' and params[:address][:css] == '' and params[:address][:regexp] == ''
					params[:address][:css] = '#cwrapper table .ccol4' 
				end

				if ["eportal.pwr.wroc.pl", "eportal-iz.pwr.wroc.pl", "eportal-ch.pwr.wroc.pl"].find do |element| params[:address][:adres].include? element end
					params[:address][:css] = '#middle-column'
				end
			
				if ["eportal.pwr.wroc.pl", "eportal-iz.pwr.wroc.pl", "eportal-ch.pwr.wroc.pl", "eportal.ii.pwr.wroc.pl/w08"].find do |element| params[:address][:adres].include? element end
					params[:address][:one_user] = true
					params[:address][:private] = true
				else
					params[:address][:one_user] = false
				end
			
				params[:address][:data_spr] = Time.new - (1.0/24/60) * 60
				params[:address][:data_mod] = Time.new
				params[:address][:blokada] = false
				
				params[:address][:opis] == 'twój opis' if params[:address][:opis] == ''
				
				new_params = Marshal.load(Marshal.dump(params.dup()))
				addresses_pending << new_params
			end

			puts addresses_pending.to_yaml

			addresses_pending.each do |params|

				# Poszukiwanie istniejących wpisów
				
				@items_matching = Address.where(:adres => params[:address][:adres], :xpath => params[:address][:xpath], :css => params[:address][:css], :regexp => params[:address][:regexp], :one_user => params[:address][:one_user])
				existing_item = nil; existing_alias = nil;
	
				unless (@items_matching.empty?)
					
					if (params[:address][:one_user])
	
						@items_matching.each do |item|
		
							unless (item.users.empty?)
								if (item.users.first.id == current_user.id)
									existing_item = item
									existing_alias = true
								end
							end
			
						end
		
					else
	
						existing_item = @items_matching.first
						@items_matching.first.users.each do |user|
							existing_alias = true if (user.id == current_user.id)
						end
		
					end
				end


				# Tworzenie brakujących wpisów

				if (existing_item)
	
					# Ewentualnie dowiąż
					if existing_alias
						message += "Adres znajduje się już na liście. \n"
					else
						if Site.new(:user_id => current_user.id, :opis => params[:address][:opis], :address_id => existing_item.id).save
							success += 1
							message += "Dodano adres do listy obserwowanych. \n"
						else
							failed += 1
							message += "Wystąpił błąd podczas dodawania adresu."
						end
					end
	
				else

					# Utwórz i dowiąż
					@address = Address.new(params[:address])
					if @address.save
						if Site.new(:user_id => current_user.id, :opis => params[:address][:opis], :address_id => @address.id).save
							success += 1
							message += "Dodano adres do listy obserwowanych. \n"
						else
							failed += 1
							message += "Wystąpił błąd podczas dodawania adresu"
						end
					end

				end

			end
			
			if (eportal != nil)
				not_added = addresses_pending.count - success;
				messages = []

				messages << "Dodano adres do listy obserwowanych." if (success == 1)
				messages << "Dodano #{success} adresy do listy obserwowanych." if (success > 1 and success < 5)
				messages << "Dodano #{success} adresów do listy obserwowanych." if (success > 4)
		
				if not_added > 0
					messages << "Adres znajduje się już na liście." if (not_added == 1)
					messages << "#{not_added} adresy znajdują się już na liście." if (not_added > 1 and not_added < 5)
					messages << "#{not_added} adresów znajduje się już na liście." if (not_added > 4)
				end
		
				messages << "Nie udało się dodać (#{failed}) adresów." if (failed > 0)
				message = messages.join("\n")
			end
		end

		respond_to do |format|
			if success > 0 or eportal
			
				if eportal and subscribed == nil
					message = "Koliber nie jest w stanie zalogować się na wybrany przez Ciebie ePortal.\n"
				
					if (eportal == 'eportal-ch.pwr.wroc.pl' and not current_user.fire_login.empty? and not current_user.fire_password.empty?) or (eportal == 'eportal-iz.pwr.wroc.pl' and not current_user.air_login.empty? and not current_user.air_password.empty?) or (eportal == 'eportal.pwr.wroc.pl' and not current_user.earth_login.empty? and not current_user.earth_password.empty?)
						message += "Upewnij się, że podane przez Ciebie hasło jest prawidłowe.\n" 
					else
						message += "Konieczne jest podanie właściwego loginu i hasła."
					end
				end
				
				
				format.html { redirect_to(przekierowanie, :notice => message) }
			else
				@address = Address.new(params[:address])
				format.html { render :action => "new", :notice => "Podany adres znajduje się już na liście"}
			end
		end
	end

	def update
	
		if params[:address][:adres] != ''
			params[:address] = popraw_usera(params[:address])
		end
		
		@address = Address.find(params[:id])

		respond_to do |format|
			if @address.update_attributes(params[:address])

				format.html { redirect_to(addresses_path, :notice => 'Message was successfully updated.') }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @address.errors, :status => :unprocessable_entity }
			end
		end
	end
	
	def destroy		
		@address = Address.find(params[:id])
		@address.destroy

		respond_to do |format|
			format.html { redirect_to addresses_url }
			format.xml	{ head :ok }
		end
	end
	
end

