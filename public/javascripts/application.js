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
	insdel();
	$("#rss_web #update").load("/rss/update", function() {insdel();});
	
	// Filtr w user/edit
	$("#filtr").keypress(function(e) {
		$('#filtr').css({color:"black"})
		var key = e.which;

		if (key == 27) {	
			$(this).val('');	
			$('#my_addresses div').css({display: "block"});
		} 
		else if (key > 31 && key < 126 || key == 8) { 
			if (key != 8) 
				var filter = $(this).val() + String.fromCharCode(key);
			else 
				var filter = $(this).val().slice(0, -1);
			filtruj(filter);
		}
	});

	function filtruj(filter) {
		var hide_them = new Array();
		$("#my_addresses div ").each(function () {
			if (($(this).children('p.opis').text().search(new RegExp(filter, "i")) < 0) && ($(this).children('p.adres').text().search(new RegExp(filter, "i")) < 0)) {
				hide_them.push($(this));
			} else {
				$(this).show();
			}
		});
		if ( hide_them.length == $("#my_addresses div").length) {
			$("#my_addresses div").each(function () {
				$(this).show();
			});
			$('#filtr').css({color:"red"});
		}
		else {
			$.each(hide_them, function (index,value) {
				value.hide();
			});
		}
	}
	
});

