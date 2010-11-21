def sklejenie_warunkowe(elementy)
	elementy = elementy.find_all{ |element| element != '' }
	return str = elementy.join(' ')
end

def popraw_usera(adres)
	# hack dla wygody
	if (adres =~ /^http(s)?:\/\//) == nil
		adres = "http#{$1}://" + adres
	end
	
	# hack na bibliotekę:
	if adres =~ /aleph\.bg\.pwr\.wroc\.pl\/F\/([^?]*)/
		adres.gsub! $1, ''
	end
	return adres
end

class AddressesController < ApplicationController
	skip_before_filter :require_admin_login, :only => [:new, :create]
	
	# GET /addresses
	# GET /addresses.xml
	def index
		@addresses = Address.order("opis ASC")
		#@messages = Message.all
		
		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @addresses }
		end
	end

	# GET /addresses/1
	# GET /addresses/1.xml
	def show
		@address = Address.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml	{ render :xml => @address }
		end
	end

	# GET /addresses/new
	# GET /addresses/new.xml
	def new
		@address = Address.new
		
		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @address }
		end
	end

	# GET /addresses/1/edit
	def edit
		@address = Address.find(params[:id])
	end

	# POST /addresses
	# POST /addresses.xml
	
	# if (@previous.private and !@address.private) @previous.private = false end
	
	def create
		dobrze = false
	
		if params[:address][:adres] != ''
			params[:address][:adres] = popraw_usera(params[:address][:adres])

			if params[:address][:adres] =~ /(portal|wa|wbliw|wch|weka|weny|wggg|wis|wiz|wme|wm|wppt|wemif)\.pwr\.wroc\.pl/ and params[:address][:xpath] == '' and params[:address][:css] == '' and params[:address][:regexp] == ''
				params[:address][:css] = '#cwrapper table .ccol4' 
			end

			params[:address][:klucz] = Digest::MD5.hexdigest(sklejenie_warunkowe([params[:address][:adres], params[:address][:xpath], params[:address][:css], params[:address][:regexp]]))
			params[:address][:data_spr] = Time.new
			params[:address][:data_mod] = Time.new
			params[:address][:blokada] = false
		end

		przekierowanie = ustawienia_path
		
		respond_to do |format|
			@previous = Address.where(:adres => params[:address][:adres], :xpath => params[:address][:xpath], :css => params[:address][:css], :regexp => params[:address][:regexp]).first
			
			if(@previous == nil)
				@address = Address.new(params[:address])
				if @address.save
					dobrze = true if Site.new(:user_id => current_user.id, :opis => params[:address][:opis], :address_id => @address.id).save
				end
			else
				@previous_site = Site.where(:user_id => current_user.id, :address_id => @previous.id).first
				if @previous_site == nil
					if Site.new(:user_id => current_user.id, :opis => params[:address][:opis], :address_id => @previous.id).save
						dobrze = true
					else
						dobrze = false
					end
				else
					dobrze = true;
				end
			end
			
			if (dobrze)
				format.html { redirect_to(przekierowanie, :notice => 'Dodano stronę.') }
				format.xml	{ render :xml => @address, :status => :created, :location => @address }
			else
				format.html { render :action => "new" }
				format.xml	{ render :xml => @address.errors + @site.errors , :status => :unprocessable_entity }
			end
		end
		
	end

	# PUT /addresses/1
	# PUT /addresses/1.xml
	def update
	
		if params[:address][:adres] != ''
			
			params[:address][:adres] = popraw_usera(params[:address][:adres])
			
			# hack na polibude
			if params[:address][:adres] =~ /(portal|wa|wbliw|wch|weka|weny|wggg|wis|wiz|wme|wm|wppt|wemif)\.pwr\.wroc\.pl/ and params[:address][:xpath] == '' and params[:address][:css] == '' and params[:address][:regexp] == ''
				params[:address][:css] = '#cwrapper table .ccol4' 
			end
			
			# klucz obliczany na podstawie adresu, xpath'a, css'a oraz regexp'a
			params[:address][:klucz] = Digest::MD5.hexdigest(sklejenie_warunkowe([params[:address][:adres], params[:address][:xpath], params[:address][:css], params[:address][:regexp]]))
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

	# DELETE /addresses/1
	# DELETE /addresses/1.xml
	def destroy		
		@address = Address.find(params[:id])
		@address.destroy

		respond_to do |format|
			format.html { redirect_to addresses_url }
			format.xml	{ head :ok }
		end
	end
	
end

