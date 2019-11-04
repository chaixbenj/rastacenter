/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


function forcesteppass(id) {
    document.getElementById("passorfail").value = "PASS";
    document.getElementById("step_id").value = id;
    document.getElementById("formstepaction").submit();
}

function forcestepfail(id) {
    document.getElementById("passorfail").value = "FAIL";
    document.getElementById("step_id").value = id;
    document.getElementById("formstepaction").submit();
}

function onloadiframechangestep() {
    stoploader();
    results = document.getElementById("hiddenFrame").contentDocument.body.innerHTML.split('||');
    for (i=0; i < results.length; i++) {
        result = results[i].split(';');
        if (result.length == 3) {
            document.getElementById("result" + result[0]).setAttribute("bgcolor", result[1]);

            document.getElementById("result" + result[0]).innerHTML = result[2];
        }
    }
}

function replace_screenshot(id_last) {
	document.getElementById("refscsh" + id_last).src = document.getElementById("runscsh" + id_last).src;
	if (document.getElementById("diffscsh" + id_last)) {
		document.getElementById("diffscsh" + id_last).parentNode.removeChild(document.getElementById("diffscsh" + id_last));
	}
	document.getElementById("btnreplace" + id_last).style.display="none";
}

function showallresults() {
	showpass = document.getElementById("spass").checked;
	showphoto = document.getElementById("sss").checked;
	document.getElementById("btndeplier" ).style.display = 'none';
	document.getElementById("btnreplier" ).style.display = null;
	elems = document.getElementsByClassName("tr_result");

	for(i=0;i<elems.length;i++) {
		if (showpass == true || (elems[i].getAttribute("status") != "pass" && elems[i].getAttribute("status") != "nodiff")) {
		}
		if ((showpass == true && showphoto == true)
		|| (showpass == false && showphoto == true && elems[i].getAttribute("status") != "pass" && elems[i].getAttribute("status") != "nodiff")
		|| (showpass == false && showphoto == false && elems[i].getAttribute("level") != "photo" && elems[i].getAttribute("status") != "pass" && elems[i].getAttribute("status") != "nodiff")
		|| (showpass == true && showphoto == false && elems[i].getAttribute("level") != "photo")) {
			elems[i].style.display = null;
			elems[i].setAttribute("expended", "true");
			if (document.getElementById("signe" + elems[i].id)) {document.getElementById("signe" + elems[i].id).innerHTML = "<b>-&nbsp;&nbsp;</b>";}
		}
	}

}

function hideallresults() {
	document.getElementById("btndeplier" ).style.display = null;
	document.getElementById("btnreplier" ).style.display = 'none';
	elems = document.getElementsByClassName("tr_result");
	signes = document.getElementsByClassName("plusmoins");
	for(i=1;i<elems.length;i++) {
		elems[i].style.display = 'none';
		elems[i].setAttribute("expended", "false");
	}
	for(i=0;i<signes.length;i++) {
		signes[i].innerHTML = "<b>+&nbsp;&nbsp;</b>";
	}
}

function showhidereportline(element) {
	showpass = document.getElementById("spass").checked;
	showphoto = document.getElementById("sss").checked;
    deplie = element.innerHTML;
    if (deplie == "<b>+&nbsp;&nbsp;</b>") {
        elements = document.getElementsByName(element.id.replace('signe',''));
        for (i = 0; i < elements.length; i++) {
			if ((showpass == true && showphoto == true)
				|| (showpass == false && showphoto == true && elements[i].getAttribute("status") != "pass" && elements[i].getAttribute("status") != "nodiff")
				|| (showpass == false && showphoto == false && elements[i].getAttribute("level") != "photo" && elements[i].getAttribute("status") != "pass" && elements[i].getAttribute("status") != "nodiff")
				|| (showpass == true && showphoto == false && elements[i].getAttribute("level") != "photo")) {
				elements[i].style.display = null;
			}
        }
		elements = document.getElementsByName(element.id.replace('signe','') + "_");
        for (i = 0; i < elements.length; i++) {
			if ((showpass == true && showphoto == true)
				|| (showpass == false && showphoto == true && elements[i].getAttribute("status") != "pass" && elements[i].getAttribute("status") != "nodiff")
				|| (showpass == false && showphoto == false && elements[i].getAttribute("level") != "photo" && elements[i].getAttribute("status") != "pass" && elements[i].getAttribute("status") != "nodiff")
				|| (showpass == true && showphoto == false && elements[i].getAttribute("level") != "photo")) {
				elements[i].style.display = null;
			}
        }
        element.innerHTML = "<b>-&nbsp;&nbsp;</b>";
		element.parentNode.parentNode.setAttribute("expended", "true");
    } else {
        elements = document.getElementsByClassName("tr_result");
        for (i = 0; i < elements.length; i++) {
         if (elements[i].getAttribute("name") && elements[i].getAttribute("name").indexOf(element.id.replace('signe',''))==0 && elements[i].id != element.id.replace('signe','')) {
				elements[i].style.display = 'none';
				elements[i].setAttribute("expended", "false");
				if (document.getElementById('signe' + elements[i].id)) {
					document.getElementById('signe' + elements[i].id).innerHTML = "<b>+&nbsp;&nbsp;</b>";
				}
			}
        }
        element.innerHTML = "<b>+&nbsp;&nbsp;</b>";
		element.parentNode.parentNode.setAttribute("expended", "false");
	}
	}

function showhidepass(btn) {
	showphoto = document.getElementById("sss").checked;
	showpass = document.getElementById("spass").checked;
	if (showpass == false && btn == 'spass') {
		showallresults();
	}
	elems = document.getElementsByClassName("tr_result");
	if (elems.length > 1) {
		elems[0].style.display = null;
		for(i=1;i<elems.length;i++) {

			father = document.getElementById(elems[i].getAttribute("name"));
			if (father && father.getAttribute("expended") == "true") {
				if ((showpass == true && showphoto == true)
					|| (showpass == false && showphoto == true && elems[i].getAttribute("status") != "pass" && elems[i].getAttribute("status") != "nodiff")
					|| (showpass == false && showphoto == false && elems[i].getAttribute("level") != "photo" && elems[i].getAttribute("status") != "pass" && elems[i].getAttribute("status") != "nodiff")
					|| (showpass == true && showphoto == false && elems[i].getAttribute("level") != "photo")) {
				elems[i].style.display = null;
				} else {
					elems[i].style.display = 'none';
				}
			} else {
				if (showpass == false && showphoto == true && elems[i].getAttribute("status") != "pass" && elems[i].getAttribute("status") != "nodiff") {
					elems[i].style.display = null;
				} else {
					elems[i].style.display = 'none';
				}
			}
		}
	}
}

function show_run_suite_graphe(run) {
document.getElementById('contentpopupfiche').innerHTML='<object id=\'objpopup\' width=\'99%\' data=\'../run_suite_schemes/index?popup=true&run_id=' + run + '\'></object>';
    window.location.href='#popupfiche';
    document.getElementById('popupfiche').style.display='block';
    document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);
    
    }

