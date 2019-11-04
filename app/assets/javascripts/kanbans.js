function displayfilter(elem, filtre) {
    if (document.getElementById(filtre)) {
        val = elem.getAttribute("label");
        if (elem.checked) {
            document.getElementById(filtre).innerHTML += "<span class='elemfiltreselected'>" + val + "</span>";
        } else {
            childs = document.getElementById(filtre).childNodes;
            for (i = 0; i < childs.length; i++) {
                if (childs[i].innerHTML == val) {
                    childs[i].parentNode.removeChild(childs[i]);
                }
            }
        }
    }
}

function showkbfilter() {
    hiddendivfiltre = document.getElementById('hiddendivfiltre');
     if (hiddendivfiltre.style.display != 'block') {
        initheight = document.getElementById("contentkanban").style.height;
        hiddendivfiltre.style.display = 'block';
        setCookie("alfyftkanbanfilter", "block");
        document.getElementById("contentkanban").style.height = (document.getElementById("contentkanban").offsetHeight - hiddendivfiltre.offsetHeight) + "px";
    }
}

function showhidekbfilter() {
    hiddendivfiltre = document.getElementById('hiddendivfiltre');
     if (hiddendivfiltre.style.display != 'block') {
        initheight = document.getElementById("contentkanban").style.height;
        hiddendivfiltre.style.display = 'block';
		hiddendivmaj.style.display = 'none';
        setCookie("alfyftkanbanfilter", "block");
        document.getElementById("contentkanban").style.height = (document.getElementById("contentkanban").offsetHeight - hiddendivfiltre.offsetHeight) + "px";
    } else {
        hiddendivfiltre.style.display = 'none';
        setCookie("alfyftkanbanfilter", "none");
        document.getElementById("contentkanban").style.height = "calc(100% - 50px)";
    }
}

function showhidekbmasseupdt() {
    hiddendivmaj = document.getElementById('hiddendivmaj');
	hiddendivfiltre = document.getElementById('hiddendivfiltre');
     if (hiddendivmaj.style.display != 'block') {
		hiddendivfiltre.style.display = 'none';
        initheight = document.getElementById("contentkanban").style.height;
        hiddendivmaj.style.display = 'block';
        setCookie("alfyftkanbanfilter", "none");
        document.getElementById("contentkanban").style.height = (document.getElementById("contentkanban").offsetHeight - hiddendivmaj.offsetHeight) + "px";
    } else {
        hiddendivmaj.style.display = 'none';
        document.getElementById("contentkanban").style.height = "calc(100% - 50px)";
    }
}

function showhidekbfilteronload() {
    actualshow = getCookie("alfyftkanbanfilter");
    if (actualshow && actualshow == "block") 
    {
        hiddendivfiltre = document.getElementById('hiddendivfiltre');
        hiddendivfiltre.style.display = 'block';
        document.getElementById("contentkanban").style.height = (document.getElementById("contentkanban").offsetHeight - hiddendivfiltre.offsetHeight) + "px";
    }
    
}


function displaykanbansaveas() {
    hiddensaveasdiv = document.getElementById('hiddensaveasdiv');
     if (hiddensaveasdiv.style.display != 'block') {
        hiddensaveasdiv.style.display = 'block';
        document.getElementById('imagesave').style.display = 'none';
    } 
}

function verifkanbanname() {
	if (document.getElementById('ecraser')) {
        if (document.getElementById('ecraser').checked==false) {
             document.getElementById('newkanbanname').required=true;
        } else {
            document.getElementById('newkanbanname').required=false;
        }
        } else {
            document.getElementById('newkanbanname').required=true;
        }
}




function checkAllFiche()
 {
	var table = document.getElementById('flex');
     var checkboxes = table.querySelectorAll('input[type=checkbox]');
     var val = checkboxes[0].checked;
     for (var i = 0; i < checkboxes.length; i++) checkboxes[i].checked = val;
 }
 
 function checkShiftFiche(event, chk)
 {
  
  if (event.shiftKey){
		var val = document.getElementById(lastClicked).checked;
		shiftClicked = chk;
		
		var table = document.getElementById('flex');
		var checkboxes = table.querySelectorAll('input[type=checkbox]');
		var startClick=false;
		var endClick=false;

		for (var i = 0; i < checkboxes.length; i++) {
			if (startClick==true && (checkboxes[i].id==lastClicked || checkboxes[i].id==shiftClicked)) {

				endClick = true;
				startClick = false;
			}
			if (startClick==false && endClick==false && (checkboxes[i].id==lastClicked || checkboxes[i].id==shiftClicked)) {
				startClick = true;
			}
			if (startClick) {
			checkboxes[i].checked = val;
			}
		}
		
    } else {
		lastClicked=chk;	
	}
 }
 
 function updidstomaj() {
	 document.getElementById("massids").value = "";
	checkboxes = document.getElementsByName("ckbxfic"); 
	for (var i = 0; i < checkboxes.length; i++) {
		if (checkboxes[i].checked) {document.getElementById("massids").value += checkboxes[i].id + ";";}
	}
 }
 
 function setselectedlinkto() {
var g = $('#inputladdfs').val();
var id = $('#laddfs option[value="' + g +'"]').attr('id');
$('#laddf').val(id);
}

function get_filtered_linked_fiche(str) {
	xhrgl = new XMLHttpRequest();
	startloader();
    xhrgl.open('GET', "../fiches/get_fiches_filtered?str=" + str, true);
    xhrgl.onreadystatechange = function () {
        if (xhrgl.readyState === 4) {
            //alert(xhr.responseText);
			if (xhrgl.responseText!="") {document.getElementById('laddfs').innerHTML = xhrgl.responseText;}
			stoploader();
        }
    };
    xhrgl.send(null);
}
