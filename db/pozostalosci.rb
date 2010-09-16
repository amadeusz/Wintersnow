Niestety, wprowadzono błędny genotyp.<br /> <span class="smaller2">Spróbuj jeszcze raz, może to była tylko literówka</span>

Oto Twój nowy koliber: <span id="name"> <%= @user.klucz %></span>.</p> <p>Od teraz jego zadaniem jest dostarczać Ci wiadomości o zmianach na stronie. <a href="/users/<%= @user.klucz %>/edit"> Powiedz mu, na które strony ma zwrócić uwagę <a></p>

	
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

