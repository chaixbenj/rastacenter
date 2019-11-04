// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
window.onLoad = function(callback) {
  // binds ready event and turbolink page:load event
  $(document).ready(callback);
  $(document).on('page:load',callback);
};

function setCookie(cname, cvalue) {
    document.cookie = cname + "=" + cvalue;
    getCookie(cname);
}


function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}

function deletePasteCookies() {
    setCookie("domelement_copy","");
    setCookie("procedure_copy_name","");
	setCookie("procedure_copy_id","");
    setCookie("sheet_or_folder_to_paste","");
    setCookie("test_or_folder_to_paste","");
	setCookie("atdd_test_or_folder_to_paste","");
    setCookie("testsuite_to_paste","");
    setCookie("campain_to_paste","");
    setCookie("conception_sheetsheet_or_folder_to_paste","");
    setCookie("test_suitesheet_or_folder_to_paste","");
    setCookie("step_to_paste0","");
	setCookie("step_to_paste1","");
    setCookie("testsuite_to_paste","");   
}

function shownotification() {
	if (document.getElementById('notification').style.display=='none') {
		document.getElementById('contentnotification').innerHTML='<object id=\'objnotif\' width=\'99%\' data=\'../user_notifications/index\'></object>';
		//window.location.href='#notification';
		document.getElementById('notification').style.display='block';
		document.getElementById('objnotif').setAttribute('height',  document.body.offsetHeight);
	}
}

function new_fiche(type_fiche, step_id, father_id) {
    document.getElementById('contentpopupfiche').innerHTML='<object id=\'objpopup\' width=\'99%\' data=\'../fiches/new?type_fiche=' + type_fiche + '&father_id=' + father_id + '&step_id=' + step_id + '\'></object>';
    window.location.href='#popupfiche';
    document.getElementById('popupfiche').style.display='block';
    document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);
	document.getElementById('buttonmaxfiche').style.display="block";
    
    }

function show_fiche(id) {
    document.getElementById('contentpopupfiche').innerHTML='<object id=\'objpopup\' width=\'99%\' data=\'../fiches/edit?fiche_id=' + id + '\'></object>';
    window.location.href='#popupfiche';
    document.getElementById('popupfiche').style.display='block';
    document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);
	document.getElementById('buttonmaxfiche').style.display="block";
    }
	
function show_selected_fiche() {
	var g = $('#inputlayoutaddfs').val();
	var id = $('#layoutaddfs option[value="' + g +'"]').attr('id');
	$('#inputlayoutaddfs').val("");
    document.getElementById('contentpopupfiche').innerHTML='<object id=\'objpopup\' width=\'99%\' data=\'../fiches/edit?fiche_id=' + id + '\'></object>';
    window.location.href='#popupfiche';
    document.getElementById('popupfiche').style.display='block';
    document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);
	document.getElementById('buttonmaxfiche').style.display="block";
    }
	
    var divleft = undefined;
	var divright = undefined;
	var puceresize = undefined;
function startresizediv(e, elem) {
  divleft = document.getElementById("left");
  divright = document.getElementById("right");
  puceresize = elem;
  divleft.setAttribute("onmousemove", "resizediv(event);");
  divleft.setAttribute("onmouseup", "stopresizediv(event);");
  divright.setAttribute("onmousemove", "resizediv(event);");
  divright.setAttribute("onmouseup", "stopresizediv(event);");
}

function resizediv(e) {
	if (divleft) {
		newpos = e.clientX + 3;
		divleft.style.width = newpos + 'px';
		divright.style.width = "calc(100% - " + newpos + 'px)';
		puceresize.style.left = e.clientX + 'px';
	}
}

function stopresizediv(e) {
  divleft.removeAttribute("onmousemove");
  divleft.removeAttribute("onmouseup");
  divright.removeAttribute("onmousemove");
  divright.removeAttribute("onmouseup");
  divleft = undefined;
  divright = undefined;
  puceresize = undefined;
  
  lssizeleft = localStorage.getItem("alfyftsizeleft");
  if (lssizeleft == null) {
	localStorage.setItem("alfyftsizeleft","");
  }
  lssizeleft = e.clientX + 3;
  localStorage.setItem("alfyftsizeleft", lssizeleft);
}
	
function openimage(el) {
	var image = new Image();
    image.src = el.src;
	image.setAttribute("width", "100%");
    var w = window.open("", "_blank");
    w.document.write(image.outerHTML);
}


function plusSlides(n) {
  showSlides(slideIndex += n);
}

function currentSlide(n) {
  showSlides(slideIndex = n);
}

function showSlides(n) {
  var i;
  var slides = document.getElementsByClassName("mySlides");
  var dots = document.getElementsByClassName("dot");
  if (n > slides.length) {slideIndex = 1}    
  if (n < 1) {slideIndex = slides.length}
  for (i = 0; i < slides.length; i++) {
      slides[i].style.display = "none";  
  }
  for (i = 0; i < dots.length; i++) {
      dots[i].className = dots[i].className.replace(" active", "");
  }
  slides[slideIndex-1].style.display = "block";  
  dots[slideIndex-1].className += " active";
}

function majnotif(ecran) {
	stoploader();
	retour = document.getElementById("hiddenframenotif").contentDocument.body.innerHTML;
    if (retour.indexOf("deleted") >= 0) {
        retour = retour.replace("deleted;","");
		notif = document.getElementById("notif" + retour);
		notif.parentNode.removeChild(notif);
    }
	if (retour.indexOf("seen") >= 0) {
		retour = retour.replace("seen;","");
		if (ecran=="main") {
			notif = document.getElementById("notif" + retour);
			notif.parentNode.removeChild(notif);
		} else {
			seen = document.getElementById("seen" + retour);
			seen.parentNode.removeChild(seen);
			notif = document.getElementById("notif" + retour);
			notif.style = "border-style:none;width:80%;float:left;";
		}
    }
}

function get_filtered_fiche_layout(str) {
	xhrgllay = new XMLHttpRequest();
	startloader();
    xhrgllay.open('GET', "../fiches/get_fiches_filtered?str=" + str, true);
    xhrgllay.onreadystatechange = function () {
        if (xhrgllay.readyState === 4) {
            //alert(xhr.responseText);
			if (xhrgllay.responseText!="") {document.getElementById('layoutaddfs').innerHTML = xhrgllay.responseText;}
			stoploader();
        }
    };
    xhrgllay.send(null);
}