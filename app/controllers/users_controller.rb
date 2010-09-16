class UsersController < ApplicationController

	skip_before_filter :require_login, :only => [:new, :create]
	skip_before_filter :require_admin_login, :only => [:new, :create, :edit, :update]

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
		@addresses = Address.all
		widok = 'new'
		widok = 'user_new' if !(admin_logged_in?)
		
		respond_to do |format|
			format.html { render widok } # new.html.erb
			format.xml	{ render :xml => @user }
		end
	end
	
	# GET /users/1/edit
	def edit
		if admin_logged_in? and params[:id].nil? == false
			@user = User.find(params[:id])
		else
			@user = current_user
		end
		@addresses = Address.all
		
		respond_to do |format|
			format.html 
			format.js {render :layout => false}
		end
	end

	# POST /users
	# POST /users.xml
	def create

		genotyp = nil
		genotyp = Genotype.find(:first, :conditions => { :genotyp => params[:genotyp] }) if params[:genotyp] != nil
		
		autoryzowane = false		
		autoryzowane = true if admin_logged_in?
		autoryzowane = true if !admin_logged_in? && !genotyp.nil?

		widok = 'new'
		widok = 'user_new' if !(admin_logged_in?)
		
		przekierowanie = users_path
		przekierowanie = root_path if !(admin_logged_in?)
		
		if !admin_logged_in? && !genotyp
			flash[:error] = "Nieprawidłowy genotyp."
		else
			flash[:error] = nil
		end
		
		@user = User.new(params[:user])
		@addresses = Address.all

		respond_to do |format|
			if autoryzowane && @user.save
				genotyp.destroy if !admin_logged_in?
				format.html { redirect_to(przekierowanie, :notice => 'Możesz się teraz zalogować') }
				format.xml	{ render :xml => @user, :status => :created, :location => @user }
			else
				format.html { render widok, :action => "new" }
				format.xml	{ render :xml => @user.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /users/1
	# PUT /users/1.xml
	def update
		@user = User.find(params[:id])
		
#		@filtry = params[:filters]
#		if @filtry != nil
#			params[:user][:obserwowane] = @filtry.join(" ")
#		else
#			params[:user][:obserwowane] = nil
#		end
		przekierowanie = users_path
		przekierowanie = root_path if !(admin_logged_in?)

		respond_to do |format|
			if @user.update_attributes(params[:user])
				format.html { redirect_to(przekierowanie, :notice => 'Ustawienia pomyślnie zapisane') }
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

end
