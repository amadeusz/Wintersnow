$(document).ready( function() {
	$("#genotypes input[type=text]:last").focus();

	$("#addresses_new input[type=text]:first").focus();
	$("#addresses_create input[type=text]:first").focus();
	$("#addresses_update input[type=text]:first").focus();
	$("#addresses_edit input[type=text]:first").focus();

	$("#addresses .komunikat_id").hover(	
		function(){
			$(this).css({backgroundColor:"#FFC0CB"});
			$(this).children("div").show();
		},
		function(){
			$(this).css({backgroundColor:"transparent"});
			$(this).children("div").fadeOut(300);
		}
	);
});

