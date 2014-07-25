//A generic show/hide function that can be effectively extended by other functions (see rule-edit.js)
//It is specifically for use with sebForms - any use outside of that would be coincidental
function toggleField(field,action) {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('lbl-' + field) ) {return false;}
	
	var lblOptions = document.getElementById('lbl-' + field);
	var inpOptions;
	var oOptions;
	var dispType;
	
	if ( document.getElementById(field + '_set') ) {
		inpOptions = document.getElementById(field + '_set');
	} else {
		inpOptions = document.getElementById(field);
	}
	
	if ( lblOptions.parentNode.nodeName == "DIV" ) {
		oOptions = lblOptions.parentNode;
		dispType = 'block';
	} else if ( lblOptions.parentNode.parentNode.nodeName == "DIV" ) {
		oOptions = lblOptions.parentNode.parentNode;
		dispType = 'block';
	} else if ( lblOptions.parentNode.parentNode.nodeName == "TR" ) {
		oOptions = lblOptions.parentNode.parentNode;
		dispType = 'table-row';
	} else if ( lblOptions.parentNode.parentNode.parentNode.nodeName == "TR" ) {
		oOptions = lblOptions.parentNode.parentNode;
		dispType = 'table-row';
	}
	
	if ( action == 'hide' ) {
		oOptions.style.display = "none";
		lblOptions.style.display = "none";
		inpOptions.style.display = "none";
	} else {
		try {
			oOptions.style.display = dispType;
		} catch (err) {
			oOptions.style.display = "block";
		}
		lblOptions.style.display = "block";
		inpOptions.style.display = "block";
	}
}
function showOptions(type) {
	if (!document.getElementById) {return false;}
	if ( arguments.length >= 2 ) {
		field = arguments[1];
	} else {
		field = arguments[0];
	}
	var allOptions = document.getElementById('all' + type + '_1');
	
	if ( allOptions.checked ) {
		toggleField(field,'hide')
	} else {
		toggleField(field,'show')
	}
}

function showPermissions(type) {
	if (!document.getElementById) {return false;}
	field = 'Permissions';
	var isUniversal = document.getElementById('isUniversal_1');
	if ( isUniversal.checked ) {
		toggleField(field,'hide')
	} else {
		toggleField(field,'show')
	}
}

$(document).ready(function(){				
	showPermissions();
});
