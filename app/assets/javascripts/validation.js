function disabledForm(formid) {
var form = document.getElementById(formid);
if (document.getElementById(formid)) {
    var form = document.getElementById(formid);
var length = form.elements.length,
    i;
  for (i=0; i < length; i++) {
    form.elements[i].disabled = true;
  }
}
}

function showvalidbtn() {
	document.getElementById('btnval').style.display='inline';
}

function showvalidbtnid(id) {
	document.getElementById('btnval'+id).style.display='inline';
}

function showversionbtn() {
	document.getElementById('btnversion').style.display='inline';
}

function showupdateform(id) {
	document.getElementById("formupdt" + id).style.display="inline";
}

function checknameshowvalidbtn(id, oldname) {
  if (document.getElementById("iname" + id).checkValidity()==true) {
    document.getElementById("formupdt" + id).style.display="inline";
  } else {
    document.getElementById("formupdt" + id).style.display="none";
    alert("format du nom incorrect");
    document.getElementById("iname" + id).value = oldname;
    document.getElementById("iname" + id).focus();
  }
}

function checknamevalidity(id, oldname) {
  if (document.getElementById("iname" + id).checkValidity()==true) {
  } else {
    document.getElementById("formupdt" + id).style.display="none";
    alert("format du nom incorrect");
    document.getElementById("iname" + id).value = oldname;
    document.getElementById("iname" + id).focus();
  }
}

function checkelementshowvalidbtn(id) {
  if (document.getElementById("iname" + id).checkValidity()==true && document.getElementById("ipath" + id).checkValidity()==true) {
    document.getElementById("formupdt" + id).style.display="inline";
  } else {
    document.getElementById("formupdt" + id).style.display="none";
    alert("saisir les champs obligatoires");
  }
}

function validatevalue(elem) {
  if (elem.checkValidity()) {
	document.getElementById('btnval').style.display='inline';
  } else {
	alert('format incorrect');
	document.getElementById('btnval').style.display='none';
	this.value = "";
	this.focus();
  }
}

function showvalidifdest() {
	var showvalid=false;
	var checkedids = ""
    var checkboxes = document.getElementsByName("chbxinput");
     for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked == true) { 
			showvalid = true;
			checkedids += (checkboxes[i].getAttribute("value") + ";");
        }
    }
	var contact_alf = document.getElementById("contact_alf");
	if (contact_alf && contact_alf.checked == true) { 
		showvalid = true;
		checkedids += "superadmin;";
	}

	if (showvalid) {
		document.getElementById('btnval').style.display='inline';
		document.getElementById('checkedids').value=checkedids;
	} else {
		document.getElementById('btnval').style.display='none';
	}
 }