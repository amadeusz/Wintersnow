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

	// Nowy adres, zaawansowane
	
	$("#users #expert").hide();
	$("#users #expert_toggle").live('click', function() {
		if(!$('#users #new_address').haveClass('disabled')) {
			$('#users #expert').show()
			$('#users #expert_toggle').hide()
		}
	});
	$("#users #expert img").live('click', function() {
		$('#users #expert').hide()
		$('#users #expert_toggle').show()
	});
	
	// Zaznaczenie sugerowanego adresu wyłącza ręczne dodawanie
	
	$("#users #sugerowane input[type=checkbox]").change( function() {
		var count = 0;
		$("#users #sugerowane input[type=checkbox]").each( function() {
			if($(this).is(':checked') && $(this).is(':visible')) count++;
		});
		
		if(count > 0) {
			$("#users #new_address input").attr('disabled', 'true');
			$("#users #new_address").addClass('disabled');
		}
		else {
			$("#users #new_address input").removeAttr('disabled');
			$("#users #new_address").removeClass('disabled');
		}
	});
	
	$("#web").load("/rss/update");
	
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
	
	var subskrybowane = ($("#subskrybowane input[type=checkbox]").length > 0);

	$('#my_addresses').parent().hide();
	if(!subskrybowane) $('#my_addresses').parent().parent().hide();
	

	function filtruj(filter) {
		var hide_them = new Array();
		$("#my_addresses li").each(function () {
			if (($(this).children('.opis').text().search(new RegExp(filter, "i")) < 0) && ($(this).children('.adres').text().search(new RegExp(filter, "i")) < 0)) {
				hide_them.push($(this));
			} else {
				$(this).show();
			}
		});
		if ( hide_them.length == $("#my_addresses li").length || hide_them.length == 0) {
//			$("#my_addresses li").each(function () {
//				$(this).show();
//			});
//			$('#my_addresses').parent().parent().hide(); //$('#filtr').css({color:"red"});
			$('#my_addresses').parent().hide();
			if(!subskrybowane) $('#my_addresses').parent().parent().hide();
		}
		else {
			$.each(hide_them, function (index,value) {
				value.fadeOut();
			});
			
			if(!subskrybowane) $('#my_addresses').parent().parent().show();
			$('#my_addresses').parent().show(); //$('#filtr').css({color:"black"});
		}
	}
	
	// Karty w Ustawieniach
	
	function ukryj_wszystkie_panele() {
		$('#users #configuration #haslo').hide();
		$('#users #configuration #subskrypcja').hide();
	}
	
	function odznacz_wszystkie_karty() {
		$('#users #configuration #haslo_tab').removeClass('aktywna');
		$('#users #configuration #subskrypcja_tab').removeClass('aktywna');
	}
	
	ukryj_wszystkie_panele();
	$('#users #configuration #subskrypcja_tab').addClass('aktywna');
	$('#users #configuration #subskrypcja').show();
	$('#users .karty').show();
	
	$('#users #configuration #haslo_tab').click( function() {
		ukryj_wszystkie_panele(); $('#users #configuration #haslo').show();
		odznacz_wszystkie_karty(); $(this).addClass('aktywna');
	} );

	$('#users #configuration .karty #subskrypcja_tab').click( function() {
		ukryj_wszystkie_panele(); $('#users #configuration #subskrypcja').show();
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

