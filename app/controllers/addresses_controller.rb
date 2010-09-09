class AddressesController < ApplicationController
  # GET /addresses
  # GET /addresses.xml
  def index
    @addresses = Address.all
    @messages = Message.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @addresses }
    end
  end

  # GET /addresses/1
  # GET /addresses/1.xml
  def show
    @address = Address.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @address }
    end
  end

	# GET /addresses/new
	# GET /addresses/new.xml
	def new
		@address = Address.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml  { render :xml => @address }
		end
	end

	# GET /addresses/1/edit
	def edit
		@address = Address.find(params[:id])
	end

	# POST /addresses
	# POST /addresses.xml
	def create
		puts params[:address].inspect.to_yaml
		if (params[:address][:adres] =~ /^http:\/\//) == nil
			params[:address][:adres] = "http://" + params[:address][:adres]
		end
		params[:address][:klucz] = Digest::MD5.hexdigest(params[:address][:adres])
		params[:address][:data_spr] = Time.new
		params[:address][:data_mod] = Time.new
		params[:address][:blokada] = false

		@address = Address.new(params[:address])

		respond_to do |format|
			if @address.save
				format.html { redirect_to (@address, :notice => 'Message was successfully created.') }
				format.xml  { head :ok }
			else
				format.html { render :action => "new" }
				format.xml  { render :xml => @address.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /addresses/1
	# PUT /addresses/1.xml
	def update
		@address = Address.find(params[:id])

		respond_to do |format|
			if @address.update_attributes(params[:address])

				format.html { redirect_to(@address, :notice => 'Message was successfully updated.') }
				format.xml  { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml  { render :xml => @address.errors, :status => :unprocessable_entity }
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
			format.xml  { head :ok }
		end
	end
  
end
