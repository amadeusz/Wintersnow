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
			if (($(this).children('p.opis').text().search(new RegExp(filter, "i")) < 0) && ($(this).children('p.adres').text().search(new RegExp(filter, "i")) < 0)) {
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
				value.slideUp();
			});
			$('#filtr').css({color:"black"});
		}
	}
	
	// checkCheckbox.onClick
	
	$('#my_addresses input[type=text]').click( function() {
		opis = $(this).val();
		checkbox = $(this).parent().find('input[type=checkbox]');
		checkbox.attr('checked', true);
		if(!checkbox.attr('title')) checkbox.attr('title', opis);
	} );

	$('#my_addresses input[type=checkbox]').click( function() {
		
		if($(this).attr('title') && !$(this).is(':checked'))
			$(this).parent().parent().find('input[type=text]').attr('value', $(this).attr('title'))
		
//		checkbox.attr('title', opis);
//		
//		opis = $(this).val();
//		checkbox = $(this).parent().find('input[type=checkbox]');
//		checkbox.attr('checked', true);
		
	} );	
	
});

