# users_controller.rb

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

# application.html.erb

<!--			<span style="margin-left: 10%">-->
<!--				<a href="/users/wykluj">wykluj</a>-->
<!--				<% if session[:logged_as].nil? %>-->
<!--					<a href="/users/login">su user</a>-->
<!--					<a href="/users/login_admin">su</a>-->
<!--				<% else %>-->
<!--					<a href="/users/logout">Ctrl+D</a>-->
<!--				<% end %>-->
<!--			</span>-->


# users_controller.rb

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
	
	
# new.html.erb


<% form_for(@user) do |f| %>
	<%= f.error_messages %>
	uzyty:<%= session[:uzyty_genotyp] %>
	<p>Teraz nazwij swojego małego kolibra:</p>
	<p><%= f.text_field :klucz %></p>
	<p>...i podaj hasło, które uchroni go przed drapieżnikami.<br />
	<span class="smaller">Dzięki hasłu dostęp do kolibra będziesz mieć tylko ty.</span></p>
	<p><%= f.password_field :haslo %></p>
	<p><%= f.submit 'Wykluj kolibra' %></p>
<% end %>

# edit.html.erb

<% form_for(@user) do |f| %>

	<p>
		<%= f.label "Nazwa kolibra:" %><br />
		<% if session[:logged_as] == "admin" %>
		<%= f.text_field :klucz %>
	 	<% else %>
	 	<%= @user.klucz %>
		<% end %>

	</p>
	 <p>
		<%= f.label :haslo %><br />
		<%= f.text_field :haslo %>
	</p>
	<% if @obserwowane != [] %>
		<div class="group" style="color:blue">
			<% @obserwowane.each do |find_item| %>
			<label><%= check_box_tag 'filters[]', find_item[:klucz], true %> <%= find_item[:adres] %> </label>
			<% end %>
		</div>
	<% end %>
	<div id="dodaj_adres" class="group" style="color:cyan">
		<% form_tag 'dupa' do -%>
		 <%= text_field "item", "filtr", :class => 'filtr' %>
		<% end -%>
		<ul style="list-style: none;padding:0">
		<% @find.each do |find_item| %>
		<li >
			<%= check_box_tag 'filters[]', find_item[:klucz] %> 
			<span class="opis"><%= find_item[:opis] %></span>
			<span class="adres" style="font-size:80%"><%= find_item[:adres] %></span> 
		</li>
		<% end %>
		</ul>
	</div>
	
	<p>
		<%= f.submit 'Update' %>
	</p>

<!--<script type="text/javascript">-->
<!--var adresy = $('dodaj_adres').select('p');-->
<!--adresy.each(function(item) {-->
<!--	var value1 = item.select('span').text;-->
<!--	var patt=/ain/;-->
<!--	alert("aa"+value1);-->
<!--	if (null != null) { item.hide(); };-->
<!--});-->
<!--$('dodaj_adres').setStyle({ color: 'red' });-->
<!--new PeriodicalExecuter(function(pe) {-->
<!--	$('dodaj_adres').insert({-->
<!--	'top': $F('item_search')});-->
<!--}, 2);-->
<!--</script>-->

<% end %>

<%= link_to 'Show', @user %> |
<%= link_to 'Back', users_path %>

