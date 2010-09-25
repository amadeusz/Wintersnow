def sklejenie_warunkowe(elementy)
	elementy = elementy.find_all{ |element| element != '' }
	return str = elementy.join(' ')
end

class AddressesController < ApplicationController
	skip_before_filter :require_admin_login, :only => [:new, :create]
	
	# GET /addresses
	# GET /addresses.xml
	def index
		@addresses = Address.all
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
	def create
		if params[:address][:adres] != ''
			if(params[:address][:adres] =~ /^http:\/\//) == nil
				params[:address][:adres] = "http://" + params[:address][:adres]
			end
			
			# klucz obliczany na podstawie adresu, xpath'a, css'a oraz regexp'a
			params[:address][:klucz] = Digest::MD5.hexdigest(sklejenie_warunkowe([params[:address][:adres], params[:address][:xpath], params[:address][:css], params[:address][:regexp]]))
			params[:address][:data_spr] = Time.new
			params[:address][:data_mod] = Time.new
			params[:address][:blokada] = false
		end

		@address = Address.new(params[:address])
		przekierowanie = addresses_path
		przekierowanie = root_path if !(admin_logged_in?)
		respond_to do |format|
			if @address.save 
				if !(admin_logged_in?) 
					@site = Site.new(
						:user_id => current_user.id ,
						:opis => params[:address][:opis],
						:address_id => @address.id )
				end
				if admin_logged_in? or @site.save
					format.html { redirect_to(przekierowanie, :notice => 'Dodano stronę.') }
					format.xml	{ render :xml => @address, :status => :created, :location => @address }
				else
					format.html { render :action => "new" }
					format.xml	{ render :xml => @site.errors , :status => :unprocessable_entity }
				end
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
			if(params[:address][:adres] =~ /^http:\/\//) == nil
				params[:address][:adres] = "http://" + params[:address][:adres]
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
