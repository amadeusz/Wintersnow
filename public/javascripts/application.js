function setSelectionRange(input, selectionStart, selectionEnd) {
	if (input.setSelectionRange) {
		input.focus();
		input.setSelectionRange(selectionStart, selectionEnd);
	}
	else if (input.createTextRange) {
		var range = input.createTextRange();
		range.collapse(true);
		range.moveEnd('character', selectionEnd);
		range.moveStart('character', selectionStart);
		range.select();
	}
}

function setCaretToPos (input, pos) {
	setSelectionRange(input, pos, pos);
}

$(document).ready( function() {

	// Focusowanie formularzy

	$("#addresses_new input[type=text]:first").focus();
	$("#genotypes input[type=text]:last").focus();
	$("#messages_new textarea").focus();
	$("#users_new input[type=text]:first").focus();
	$("#users_wykluj input[type=text]:first").focus();
	$("#login input[type=text]:first").focus();
	$(".field_with_errors input[type=text]:first").focus(function() { setCaretToPos(this, this.value.length); });
	$(".field_with_errors input[type=text]:first").focus();

	// Tooltipy w adresach

	$("#addresses .komunikat_id").hover(	
		function(){
			$(this).css({ backgroundColor: "#FFC0CB" });
			$(this).children("div").show();
		},
		function(){
			$(this).css({ backgroundColor: "transparent" });
			$(this).children("div").fadeOut(300);
		}
	);
	$("#users table tr :nth-child(4)").click(	
		function(){
			$(this).children("div").toggle();
		}
	);
	$("#addresses table tr :nth-child(3)").click(	
		function(){
			$(this).children("div").toggle();
		}
	);
	
	// WebRSS
	
	function insdel() {
	$("#rss_web .tog_ins").click( function(){
		$(this).parent().siblings(".msg").children("ins").toggle();
	});
	$("#rss_web .tog_del").click( function(){
		$(this).parent().siblings(".msg").children("del").toggle();
	});
	}
	$("#new_address #expert").children('div').hide();
	$("#new_address #expert img").click( function(){
		$('#new_address #expert').children('div').toggle()
	});
	
	insdel();
	$("#new_addr #update").load("/rss/update", function() {insdel();});
	
	// Filtr w user/edit
	
	$("#filtr").keydown(function(e) {
		if (e.which == 27) {	
			$('#my_addresses li').show();
			$('[id=filtr]').val('');
		} 
		else {
			setInterval(function() {
				var filter = $("#filtr").val();
				filtruj(filter);
			}, 1000);
		}
	});

	function filtruj(filter) {
		var hide_them = new Array();
		$("#my_addresses li").each(function () {
			if (($(this).children('.opis').text().search(new RegExp(filter, "i")) < 0) && ($(this).children('.adres').text().search(new RegExp(filter, "i")) < 0)) {
				hide_them.push($(this));
			} else {
				$(this).show();
			}
		});
		if ( hide_them.length == $("#my_addresses li").length) {
			$("#my_addresses li").each(function () {
				$(this).show();
			});
			$('#filtr').css({color:"red"});
		}
		else {
			$.each(hide_them, function (index,value) {
				value.fadeOut();
			});
			$('#filtr').css({color:"black"});
		}
	}
	
	// Karty w Ustawieniach
	
	function ukryj_wszystkie_panele() {
		$('#users #edit #haslo').hide();
		$('#users #edit #inny_adres').hide();
		$('#users #edit #subskrypcja').hide();
	}
	
	function odznacz_wszystkie_karty() {
		$('#users #edit #haslo_tab').removeClass('aktywna');
		$('#users #edit #inny_adres_tab').removeClass('aktywna');
		$('#users #edit #subskrypcja_tab').removeClass('aktywna');
	}
	
	ukryj_wszystkie_panele();
	$('#users #edit #subskrypcja_tab').addClass('aktywna');
	$('#users #edit #subskrypcja').show();
	$('#users .karty').show();
	
	$('#users #edit #haslo_tab').click( function() {
		ukryj_wszystkie_panele(); $('#users #edit #haslo').show();
		odznacz_wszystkie_karty(); $(this).addClass('aktywna');
	} );

	$('#users #edit .karty #inny_adres_tab').click( function() {
		ukryj_wszystkie_panele(); $('#users #edit #inny_adres').show();
		odznacz_wszystkie_karty(); $(this).addClass('aktywna');
	} );
	
	$('#users #edit .karty #subskrypcja_tab').click( function() {
		ukryj_wszystkie_panele(); $('#users #edit #subskrypcja').show();
		odznacz_wszystkie_karty(); $(this).addClass('aktywna');
	} );
	
	// Checkboxy w subskrypcji
	
	$('#my_addresses input[type=text]').attr('disabled', true);
	
	$('#my_addresses input[type=checkbox]').click( function() {
		
		pole = $(this).parent().parent().find('input[type=text]')
		
		if ($(this).is(':checked')) {
			pole.attr('disabled', false);
			opis = pole.val();
			$(this).attr('title', opis);
		}
		else {
			pole.attr('disabled', true);
			opis = $(this).attr('title');
			pole.val(opis);
		}
	} );	
	
});

