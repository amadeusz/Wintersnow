users_controller.rb

	# GET /users
	# GET /users.xml
	def index
		respond_to do |format|
			if session[:logged_as] == "admin"
			@users = User.all
				format.html # index.html.erb
				format.xml	{ render :xml => @users }
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
				format.xml	{ render :xml => @user }
			end
		else 
			respond_to do |format|
				format.html { redirect_to( :action => "edit") }
			end
		end
	end
	
	def new
		if session[:logged_as] != "admin" 
			session[:first_time] = true
		end
		@user = User.new
		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @user }
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



<% if session[:logged_as] == "admin" %>

<% else %>
	<p>Oto Twój nowy koliber: <span id="name"> <%= @user.klucz %></span>.</p> <p>Od teraz jego zadaniem jest dostarczać Ci wiadomości o zmianach na stronie. <a href="/users/<%= @user.klucz %>/edit"> Powiedz mu, na które strony ma zwrócić uwagę <a></p>
	<% session[:first_time] = nil %>
<% end %>

application.html.erb

<!--			<span style="margin-left: 10%">-->
<!--				<a href="/users/wykluj">wykluj</a>-->
<!--				<% if session[:logged_as].nil? %>-->
<!--					<a href="/users/login">su user</a>-->
<!--					<a href="/users/login_admin">su</a>-->
<!--				<% else %>-->
<!--					<a href="/users/logout">Ctrl+D</a>-->
<!--				<% end %>-->
<!--			</span>-->
