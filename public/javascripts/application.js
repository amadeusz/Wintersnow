$(document).ready( function() {
	$("#genotypy input[type=text]:last").focus();

	$("#adresy .komunikat_id").hover(	
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

