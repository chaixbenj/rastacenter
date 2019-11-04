/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/* global titre_format_param, titre_param_valeur, titre_param_name, titre_param_none, titre_param_DOM */

function scrollaction(elemid) {
        if (document.getElementById(elemid) != null) {
		elem = document.getElementById(elemid);
		if (elem != null) {
			topPos = elem.offsetTop;
			document.getElementById('left').scrollTop = (topPos - document.getElementById('left').offsetTop);
			elem.setAttribute('class', 'listElementGris');
		}
	}	
}

function addActionParam() {
  tableactionparameter = document.getElementById("paramtable");
  nbparam = parseInt(document.getElementById("nbparamintable").value);
  var row = tableactionparameter.insertRow(nbparam);
  document.getElementById("nbparamintable").value = nbparam + 1;
  row.innerHTML = "<td><select id='paramtype' name='paramtype' class='lookupbox'><option selected value='none'>" + titre_param_none + "</option><option value='element'>" + titre_param_DOM + "</option><option value='value'>" + titre_param_valeur + "</option></select></td><td><input onKeyUp='formatasparam(this)' id='paramname' name='paramname' type='text' class='inputbox' placeholder='" + titre_param_name + "' size='20'  maxlength='20' pattern='[A-Za-z0-9]{1,20}' onKeyUp='formatasparam(this)' title='" + titre_format_param + "' /></td>";
	
 
}

function majHiddenActionParams() {
    var allTypes = document.getElementsByName("paramtype");
    var allNames = document.getElementsByName("paramname");
    document.getElementById("actionparameters").value = "";
    for (i=0;i<allTypes.length;i++) {
        if (allTypes[i].value != "none") {
            document.getElementById("actionparameters").value+=allTypes[i].value + "|$|" + allNames[i].value + "|$|";
        }
    }
}


function textareatab(e, txtareaCode) {
  if(e.keyCode==9 || e.which==9){
    e.preventDefault();
    var start = txtareaCode.selectionStart;
    var end = txtareaCode.selectionEnd;
    var text = txtareaCode.value;
    var before = text.substring(0, start);
    var after  = text.substring(end, text.length);

    txtareaCode.value = before + "\t" + after;
    txtareaCode.selectionStart = txtareaCode.selectionEnd = start + "\t".length
  }
}


  function buildactionidstring() 
 {
    var checkboxes = document.getElementsByName("chbxinput");
    procstring = "";
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) {
            procstring = procstring + "|" + checkboxes[i].id + "|";
        }
    }    
    document.getElementById("actionlist").value = procstring;
 }