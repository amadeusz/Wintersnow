class UsersController < ApplicationController
	# GET /users
	# GET /users.xml
	def index
		@users = User.all
		
		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @users }
		end
	end

	# GET /users/1
	# GET /users/1.xml
	def show
		@user = User.find(params[:id])
		
		respond_to do |format|
			format.html # show.html.erb
			format.xml	{ render :xml => @user }
		end
	end

	# GET /users/new
	# GET /users/new.xml
	def new
		@user = User.new
		
		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @user }
		end
	end
	
	# GET /users/1/edit
	def edit
		@user = User.find(params[:id])
		
		if @user[:obserwowane] != nil
			@obserwowane = Address.find(:all, :conditions => ["klucz IN (?)", @user[:obserwowane].split(/ /)])
			@find = Address.find(:all, :conditions => ["klucz NOT IN (?)", @user[:obserwowane].split(/ /)])
		else 
			@obserwowane = []
			@find = Address.find(:all)
		end
		
		respond_to do |format|
			format.html 
			format.js {render :layout => false}
		end
	end

	# POST /users
	# POST /users.xml
	def create
		if User.find(:all, :conditions => {"klucz" => params[:user]["klucz"]}) == []
			@user = User.new(params[:user])
		end
		
		respond_to do |format|
			if not @user.nil? and @user.save
				format.html { redirect_to(@user, :notice => 'User was successfully created.') }
				format.xml	{ render :xml => @user, :status => :created, :location => @user }
			else
				format.html { redirect_to(:action => "new")}
			end
		end
	end

	# PUT /users/1
	# PUT /users/1.xml
	def update
		@user = User.find(params[:id])
		@filtry = params[:filters]
		
		if @filtry != nil
			params[:user][:obserwowane] = @filtry.join(" ")
		else
			params[:user][:obserwowane] = nil
		end
		
		respond_to do |format|
			if @user.update_attributes(params[:user])
				format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
				format.xml	{ head :ok }
			else
				format.html { render :action => "edit" }
				format.xml	{ render :xml => @user.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /users/1
	# DELETE /users/1.xml
	def destroy
		@user = User.find(params[:id])
		@user.destroy

		respond_to do |format|
			format.html { redirect_to(users_url) }
			format.xml	{ head :ok }
		end
	end
	
	# GET /users/wykluj
	def wykluj
		if params[:q] != nil
			genotyp = Genotype.find(:first, :conditions => {:genotyp => params[:q]})
			if genotyp != nil
				flash[:notice] = nil # nie chciał się wymazać
				session[:uzyty_genotyp] = genotyp.genotyp
				redirect_to(:action => 'new')
			else 
				flash[:notice] = 'Niestety, wprowadzono błędny genotyp.<br /> <span class="smaller2">Spróbuj jeszcze raz, może to była tylko literówka</span>'
			end
		else
			respond_to do |format|
				format.html # new.html.erb
			end
		end
	end
	
	# GET /users/login
	def login
		session[:logged_as] = "user"
		respond_to do |format|
			format.html { redirect_to( :controller=> "users" , :action => "index") }
		end
	end
	
	# GET /users/login_admin
	def login_admin
		session[:logged_as] = "admin"
		respond_to do |format|
			format.html { redirect_to( :controller=> "users" , :action => "index") }
		end
	end
	
	# GET /users/logout
	def logout
		session[:logged_as] = nil
		respond_to do |format|
			format.html { redirect_to( :controller=> "users" , :action => "index") }
		end
	end

end
