def popraw_usera(params)
	
	if (params[:adres] =~ /^http(s)?:\/\//) == nil
		params[:adres] = "http#{$1}://" + params[:adres]
	end
	
	if params[:adres] =~ /aleph\.bg\.pwr\.wroc\.pl\/F\/([^?]*)/
		params[:adres].gsub! $1, ''
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
		sukces = false
	
		if params[:address][:adres] != ''
		
			params[:address] = popraw_usera(params[:address])
			
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
		end

		przekierowanie = ustawienia_path
		
		respond_to do |format|
			
			# Poszukiwanie istniejących wpisów
		
			@items_matching = Address.where(:adres => params[:address][:adres], :xpath => params[:address][:xpath], :css => params[:address][:css], :regexp => params[:address][:regexp], :one_user => params[:address][:one_user])
			existing_item = nil; existing_alias = nil
			success = false; message = '';
			
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
				
				message = "Adres znajduje się już na liście."
				
				# Ewentualnie dowiąż
				unless existing_alias
					success = true if Site.new(:user_id => current_user.id, :opis => params[:address][:opis], :address_id => existing_item.id).save
					message = "Dodano adres do listy obserwowanych."
				else
					success = true
				end
				
			else
			
				# Utwórz i dowiąż
				@address = Address.new(params[:address])
				if @address.save
					success = true if Site.new(:user_id => current_user.id, :opis => params[:address][:opis], :address_id => @address.id).save
					message = "Dodano adres do listy obserwowanych."
				end
				
			end

			if (success)
				format.html { redirect_to(przekierowanie, :notice => message) }
				format.xml	{ render :xml => @address, :status => :created, :location => @address }
			else
				format.html { render :action => "new" }
				format.xml	{ render :xml => @address.errors + @site.errors , :status => :unprocessable_entity }
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

