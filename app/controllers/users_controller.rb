class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    respond_to do |format|
    	if session[:logged_as] == "admin"
			@users = User.all
	      format.html # index.html.erb
	      format.xml  { render :xml => @users }
	    else
	      format.html { redirect_to( :controller=> "rss" , :action => "index") }
	    end
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    if session[:logged_as] == "admin" or session[:first_time] == true
		  respond_to do |format|
		    format.html # show.html.erb
		    format.xml  { render :xml => @user }
		  end
    else 
		  respond_to do |format|
		    format.html { redirect_to( :action => "edit") }
		  end
		end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
  	if session[:logged_as] != "admin" 
  		session[:first_time] = true
  	end
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  
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
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
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
        #flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
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
			format.xml  { head :ok }
		end
	end
	
	def login
		session[:logged_as] = "user"
		respond_to do |format|
			format.html { redirect_to( :controller=> "users" , :action => "index") }
		end
	end
	
	def login_admin
		session[:logged_as] = "admin"
		respond_to do |format|
			format.html { redirect_to( :controller=> "users" , :action => "index") }
		end
	end
	
	def logout
		session[:logged_as] = nil
		respond_to do |format|
			format.html { redirect_to( :controller=> "users" , :action => "index") }
		end
	end

end
