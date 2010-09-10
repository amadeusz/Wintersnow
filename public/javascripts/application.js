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
	
	
});

