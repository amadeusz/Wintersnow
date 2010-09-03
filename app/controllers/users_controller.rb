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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  
  def wykluj
		if not params[:q].nil?
			genotyp = Genotype.find(:first, :conditions => {:genotyp => params[:q]}).nil?
    end
    if genotyp == false
    	redirect_to(:action => 'new')
    else
			respond_to do |format|
				format.html # new.html.erb
			end
	  end
  end
  

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
		if @user[:obserwowane] != ""
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
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
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
			params[:user][:obserwowane] = ""
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
  def login_admin
  	@kot = session[:logged_as]
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
