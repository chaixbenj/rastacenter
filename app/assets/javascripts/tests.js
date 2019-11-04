/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


function showTestHideSons(element) {
	var cookierepertoire = "alfyfttestrepertoiredisplayed";
	if (document.getElementById("is_atdd")) {cookierepertoire = "alfyftatddtestrepertoiredisplayed";}
	repertoireDiplayed = localStorage.getItem(cookierepertoire);
	if (repertoireDiplayed == null) {localStorage.setItem(cookierepertoire,"");repertoireDiplayed = localStorage.getItem(cookierepertoire);}
    deplie = document.getElementById("signe" + element).innerHTML;
    if (deplie == "<b>+&nbsp;&nbsp;</b>") {
        elements = document.getElementsByName(element);
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'block';
        }
        document.getElementById("signe" + element).innerHTML = "<b>-&nbsp;&nbsp;</b>";
        repertoireDiplayed = repertoireDiplayed.replace("$" + element + "$", "");
        repertoireDiplayed += "$" + element + "$";
        localStorage.setItem(cookierepertoire, repertoireDiplayed);
    } else {
        elements = document.getElementsByName(element);
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'none';
        }
        document.getElementById("signe" + element).innerHTML = "<b>+&nbsp;&nbsp;</b>";
        repertoireDiplayed = repertoireDiplayed.replace("$" + element + "$", "");


        elements = document.getElementsByClassName('treegroupmore');
        for (j = 0; j < elements.length; j++) {
            if (elements[j].id.indexOf(element + "-") == 0) {
                elements[j].style.display = 'none';
                if (document.getElementById("signe" + elements[j].id) != null) {
                    document.getElementById("signe" + elements[j].id).innerHTML = "<b>+&nbsp;&nbsp;</b>";
                }
                repertoireDiplayed = repertoireDiplayed.replace("$" + elements[j].id + "$", "");
            }
        }

        elements = document.getElementsByClassName('treegroup');
        for (j = 0; j < elements.length; j++) {
            if (elements[j].id.indexOf(element + "-") == 0) {
                elements[j].style.display = 'none';
                if (document.getElementById("signe" + elements[j].id) != null) {
                    document.getElementById("signe" + elements[j].id).innerHTML = "<b>+&nbsp;&nbsp;</b>";
                }
                repertoireDiplayed = repertoireDiplayed.replace("$" + elements[j].id + "$", "");
            }
        }
    }
    localStorage.setItem(cookierepertoire, repertoireDiplayed);
}

function addSubFolder(idfolder, parent) {
	if (document.getElementById("is_atdd")) {
		repertoireDiplayed = localStorage.getItem("alfyftatddtestrepertoiredisplayed");
		if (repertoireDiplayed == null) {localStorage.setItem("alfyftatddtestrepertoiredisplayed","");repertoireDiplayed = localStorage.getItem("alfyftatddtestrepertoiredisplayed");}
		repertoireDiplayed = repertoireDiplayed.replace("$" + parent + "$", "");
		repertoireDiplayed += "$" + parent + "$";
		localStorage.setItem("alfyftatddtestrepertoiredisplayed", repertoireDiplayed);
		document.getElementById("ffolder").value = idfolder;
		startloader();
		document.getElementById("formaddatddsubfolder").submit();		
	} else {
		repertoireDiplayed = localStorage.getItem("alfyfttestrepertoiredisplayed");
		if (repertoireDiplayed == null) {localStorage.setItem("alfyfttestrepertoiredisplayed","");repertoireDiplayed = localStorage.getItem("alfyfttestrepertoiredisplayed");}
		repertoireDiplayed = repertoireDiplayed.replace("$" + parent + "$", "");
		repertoireDiplayed += "$" + parent + "$";
		localStorage.setItem("alfyfttestrepertoiredisplayed", repertoireDiplayed);
		document.getElementById("sffolder").value = idfolder;
		startloader();
		document.getElementById("formadsubfolder").submit();
	}
}


function rename_folder(idfolder) {
    oldname = document.getElementById("hidoln" + idfolder).value;
    if (document.getElementById("inputtext" + idfolder) == null) {
        document.getElementById("span" + idfolder).innerHTML = "<input id='inputtext" + idfolder + "' type='text' maxlength='250' value='" + oldname + "' onblur='document.getElementById(\"rfolder\").value=\"" + idfolder + "\";document.getElementById(\"rfoldername\").value=this.value;renameDBFolder(" + idfolder + ");revertToText(" + idfolder + ")'/>";
        document.getElementById("inputtext" + idfolder).required = true;
        document.getElementById("inputtext" + idfolder).focus();
    }
}

function renameDBFolder(idfolder) {
    if (document.getElementById("inputtext" + idfolder).value != "") {
        if (document.getElementById("inputtext" + idfolder).value != document.getElementById("hidoln" + idfolder).value) {
			document.getElementById("formrenamefolder").submit();
        }
    }
}


function revertToText(idfolder) {
    newname = document.getElementById("inputtext" + idfolder).value;
    if (newname == "") {
        newname = document.getElementById("hidoln" + idfolder).value;
    }
    document.getElementById("hidoln" + idfolder).value = newname;
    document.getElementById("span" + idfolder).innerHTML = $('<span>').text(newname).html();
}


function addTest(idfolder, parent) {
	if (document.getElementById("is_atdd")) {
		repertoireDiplayed = localStorage.getItem("alfyftatddtestrepertoiredisplayed");
		if (repertoireDiplayed == null) {localStorage.setItem("alfyftatddtestrepertoiredisplayed","");repertoireDiplayed = localStorage.getItem("alfyftatddtestrepertoiredisplayed");}
		repertoireDiplayed = repertoireDiplayed.replace("$" + parent + "$", "");
		repertoireDiplayed += "$" + parent + "$";
		localStorage.setItem("alfyftatddtestrepertoiredisplayed", repertoireDiplayed);
		document.getElementById("tfolder").value = idfolder;
		startloader();
		document.getElementById("formaddatddsteptest").submit();		
	} else {
		repertoireDiplayed = localStorage.getItem("alfyfttestrepertoiredisplayed");
		if (repertoireDiplayed == null) {localStorage.setItem("alfyfttestrepertoiredisplayed","");repertoireDiplayed = localStorage.getItem("alfyfttestrepertoiredisplayed");}
		repertoireDiplayed = repertoireDiplayed.replace("$" + parent + "$", "");
		repertoireDiplayed += "$" + parent + "$";
		localStorage.setItem("alfyfttestrepertoiredisplayed", repertoireDiplayed);
		document.getElementById("atfolder").value = idfolder;
		startloader();
		document.getElementById("formadtest").submit();
	}
}

function validArrayAtdd(stepid) {
	document.getElementById("arraystep").value = stepid;
	startloader();
	document.getElementById("formvalidarrayatdd").submit();
}

function renameTest(idtest) {
    oldname = document.getElementById("hidoltn" + idtest).value;
    if (document.getElementById("inputtexttest" + idtest) == null) {
		if (document.getElementById("is_atdd")) {
        document.getElementById("spant" + idtest).innerHTML = "<textarea cols='100' id='inputtexttest" + idtest + "' onblur='document.getElementById(\"rtest\").value=\"" + idtest + "\";document.getElementById(\"rtestname\").value=this.value;renameDBTest(" + idtest + ");revertTestToText(" + idtest + ")'>" + oldname.split("'").join("&apos;") + "</textarea>";
		} else {
        document.getElementById("spant" + idtest).innerHTML = "<input id='inputtexttest" + idtest + "' type='text' maxlength='250' value='" + oldname.split("'").join("&apos;") + "' onblur='document.getElementById(\"rtest\").value=\"" + idtest + "\";document.getElementById(\"rtestname\").value=this.value;renameDBTest(" + idtest + ");revertTestToText(" + idtest + ")'/>";
		}
        document.getElementById("inputtexttest" + idtest).required = true;
        document.getElementById("inputtexttest" + idtest).focus();
    }
}

function renameDBTest(idtest) {
    if (document.getElementById("inputtexttest" + idtest).value != "") {
        if (document.getElementById("inputtexttest" + idtest).value != document.getElementById("hidoltn" + idtest).value) {
			document.getElementById("formrenametest").submit();
			if (document.getElementById("testnamem") != null) {
                document.getElementById("testnamem").value = document.getElementById("inputtexttest" + idtest).value;
            }  
        }
    }
}


function revertTestToText(idtest) {
    newname = document.getElementById("inputtexttest" + idtest).value;
    if (newname == "") {
        newname = document.getElementById("hidoltn" + idtest).value;
    }
	if (document.getElementById("is_atdd")) {
		newname = newname.replace(/arg(\d+)/g, "1"); 
		newname = newname.replace(/^(\d+)/g, "atddargnum"); 
		newname = newname.replace(/ (\d+)/g, " atddargnum");
		newname = newname.replace(/\"([^\"]*)\"/g, "atddargstring");
		var regex = /atddargnum|atddargstring/g;
		var found = newname.match(regex);
		if (found) {
		for (i=0;i<found.length;i++) {
		  if (found[i].search(/atddargnum/)<0) {
			newname = newname.replace(found[i], "\"arg" + i + "\"");
		  } else {
			newname = newname.replace(found[i], "arg" + i);
		  }
		}
		}
	}
    document.getElementById("hidoltn" + idtest).value = newname;
    document.getElementById("spant" + idtest).innerHTML = $('<span>').text(newname).html(); 
}


function deleteFolder(idfolder) {
    if (confirm(supprimer_dossier_msg)) {
        element = document.getElementById("span" + idfolder);
        element.parentNode.parentNode.removeChild(element.parentNode);
        document.getElementById("idtodel").value = idfolder;
        document.getElementById("delwhat").value = "folder";
		document.getElementById("formdelete").submit();
    }
}


function deleteTest(idtest) {
    if (confirm(supprimer_test_msg)) {
        document.getElementById("idtodel").value = idtest;
        document.getElementById("delwhat").value = "test";
        document.getElementById("formdelete").submit();
		if (document.getElementById("is_atdd")) {
		} else {
			element = document.getElementById("spant" + idtest).parentNode;
			element.parentNode.parentNode.removeChild(element.parentNode);
			document.getElementById("right").style.display = 'none';
		}
    }
}

function onloadiframemsg() {
	if (document.getElementById("hiddenFrameMsg").contentDocument.body.innerHTML == 'ok') {
		idtest = document.getElementById("idtodel").value;
		element = document.getElementById("spant" + idtest).parentNode;
		element.parentNode.parentNode.removeChild(element.parentNode);
	} else {	
		if (document.getElementById("hiddenFrameMsg").contentDocument.body.innerHTML != '') {
		document.getElementById('messagevalide').innerHTML = "<span class='errorMessage' onclick='this.parentNode.removeChild(this)'  style='vertical-align: top;'>" + document.getElementById("hiddenFrameMsg").contentDocument.body.innerHTML + "<b>&nbsp;&nbsp;&nbsp;&nbsp;x</b></span>";
		}
	}
}

function showTest(testid) {
    document.getElementById("showtestid").value = testid;
    document.getElementById("do").value = "showtest";
    startloader();
    document.getElementById("formtestindex").submit();
}


function dragStarted(evt, elid) {
    source = document.getElementById(elid);
    evt.dataTransfer.setData("text/plain", source.innerHTML);
    evt.dataTransfer.effectAllowed = "move";
}


function draggingOver(evt, elid) {
    evt.preventDefault();
    evt.dataTransfer.dropEffect = "move";
}


function dropped(evt, elid) {
    evt.preventDefault();
    evt.stopPropagation();

    htmls = source.innerHTML;

    is = source.id.replace("divstepseq", "");
    id = elid.replace("divstepseq", "");
    document.getElementById("istart").value = is;
    document.getElementById("idest").value = id;
	document.getElementById("formreordersteps").submit();


}

function onloadiframedeletereorderchangeparamstep() {
	stoploader();
	result = document.getElementById("hiddenFrame2").contentDocument.body.innerHTML.split(';');
    if (result[0] == 'delete') {
			for (n=2;n<result.length;n++) {
            idstep = result[n];
            element = document.getElementById("divstepid" + idstep).parentNode;
            isup = element.id.replace("divstepseq", "");
            element.parentNode.removeChild(element);
            divsteps = document.getElementsByName("divstep");
            for (i = 0; i < divsteps.length; i++) {
                iseq = divsteps[i].id.replace("divstepseq", "");
                if (parseInt(iseq) > parseInt(isup)) {
                    divsteps[i].id = "divstepseq" + (parseInt(iseq) - 1);
					document.getElementById("divstepseq" + (parseInt(iseq) - 1)).setAttribute("title", (parseInt(iseq) - 1));
                }
            }
			}
		code_to_valid = "ifendforbeginend until end whilecode";	
		if (code_to_valid.indexOf(result[1]) >= 0 && result[1] != "") {	
			document.getElementById("btnvalidstruct").style.display = "inline-block";
			document.getElementById("btnlaunch").style.display = "none";
			document.getElementById("btnreport").style.display = "none";
		}
    }
	if (result[0] == 'reorder') {
        is = result[1];
        id = result[2];
        elid = "divstepseq" + id;
        if (parseInt(is) < parseInt(id)) {
            for (i = parseInt(is) + 1; i <= parseInt(id); i++) {
				if (document.getElementById("divstepseq" + (i - 1))) {
					j = i;
					while ((document.getElementById("divstepseq" + j) == null) && j <= parseInt(id)+10) {j++;}
						if (document.getElementById("divstepseq" + j)) {
						document.getElementById("divstepseq" + (i - 1)).innerHTML = document.getElementById("divstepseq" + j).innerHTML;
						document.getElementById("divstepseq" + (i - 1)).style.display = document.getElementById("divstepseq" + j).style.display;
						try {var attr = document.getElementById("divstepseq" + j).getAttribute("hidecomm") } catch (e) {attr = null;}
					}
					document.getElementById("divstepseq" + (i - 1)).setAttribute("hidecomm", attr);
				}
            }
            document.getElementById(elid).innerHTML = htmls;
        }

        if (parseInt(is) > parseInt(id)) {
            for (i = parseInt(is); i > parseInt(id); i--) {
				if (document.getElementById("divstepseq" + (i))) {
					j = i - 1;
					while ((document.getElementById("divstepseq" + j) == null) && j >= parseInt(id)-10) {j--;}
					if (document.getElementById("divstepseq" + j)) {
						document.getElementById("divstepseq" + (i)).innerHTML = document.getElementById("divstepseq" + (j)).innerHTML;
						document.getElementById("divstepseq" + (i)).style.display = document.getElementById("divstepseq" + (j)).style.display;
						try {var attr = document.getElementById("divstepseq" + (j)).getAttribute("hidecomm") } catch (e) {attr = null;}
					}
					document.getElementById("divstepseq" + (i)).setAttribute("hidecomm", attr);
				}
				
            }
            document.getElementById(elid).innerHTML = htmls;
        }
		code_to_valid = "ifendforbeginend until end whilecode";	
		if (code_to_valid.indexOf(result[3]) >= 0 && result[3] != "") {	
			document.getElementById("btnvalidstruct").style.display = "inline-block";
			document.getElementById("btnlaunch").style.display = "none";
			document.getElementById("btnreport").style.display = "none";
		}
		}
	
		if (onlycomment == true) {
		divsteps = document.getElementsByName("divstep");
			for (i = 0; i < divsteps.length; i++) {
				step_type = divsteps[i].children[0].getAttribute("step_type");
				if (step_type != "comment" && step_type != "commentodo") {
					divsteps[i].style.display = "none";
				} else {
					divsteps[i].style.display = "inline";
				}
			}
		}
	
}

function addproc() {
    document.getElementById("formaddstep").submit();
}



function deleteStep(idstep) {
    if (confirm(supprimer_step_msg)) {
        document.getElementById("step_id").value = idstep;
		startloader();
		document.getElementById("formdeletestep").submit();
    }
}


function modifparam(idel, idstep, numparam, out) {
    sequence = document.getElementById(idel).parentNode.parentNode.parentNode.id.replace("divstepseq", "");
    oldname = document.getElementById("hidden" + idel).value;
    if (document.getElementById("inputtext" + idel) == null) {
        document.getElementById('divstepseq' + sequence).setAttribute("draggable", false);
        document.getElementById(idel).innerHTML = "<input draggable=\"false\" id='inputtext" + idel + "' type='text' maxlength='5000' value='" + oldname.split("'").join("&apos;") + "' spellcheck='false' onblur='modifparam(\"" + idel + "\", " + idstep + ", " + numparam + " , \"out\");'/>";
        document.getElementById("inputtext" + idel).focus();
    } else {
        if (document.getElementById("inputtext" + idel) != null && out == 'out') {
            newname = document.getElementById("inputtext" + idel).value;
            document.getElementById("hidden" + idel).value = newname;
            document.getElementById(idel).innerHTML = "<span style=\"color:#ffffff\" class=\"textStyle\">" + newname + "</span>";
            document.getElementById('divstepseq' + sequence).setAttribute("draggable", true);
            paramvalues = document.getElementsByName("paramvalue" + idstep);
            stringparam = "";
            for (i = 0; i < paramvalues.length; i++) {
                stringparam += paramvalues[i].value + "|$|";
            }
            document.getElementById("chgtpval_params").value = stringparam;
            document.getElementById("chgtpval_stepid").value = idstep;
            document.getElementById("formchangeparamvalue").submit();
        }
    }
}

function majatddstepparamvalue(el, idstep) {
	document.getElementById("idatddstepmod").value = idstep;
	document.getElementById("atddstepparam").value = el.getAttribute("name");
	valeur = el.value;
	document.getElementById("atddstepparamvalue").value = valeur;
	document.getElementById("formvaloatddparam").submit();
}


function modifcode(elem, idstep, out, validcode) {
    sequence = elem.parentNode.parentNode.parentNode.id.replace("divstepseq", "");
    oldname = document.getElementById("hiddeninitcode" + idstep).value;
    if (document.getElementById("inputcode" + idstep) == null) {
        document.getElementById('divstepseq' + sequence).setAttribute("draggable", false);
		if (validcode) {
			if (document.getElementById("btnvalidstruct")) {document.getElementById("btnvalidstruct").style.display = "inline-block"};
			if (document.getElementById("btnlaunch")) {document.getElementById("btnlaunch").style.display = "none"};
			if (document.getElementById("btnreport")) {document.getElementById("btnreport").style.display = "none"};
		}
		if (oldname.indexOf("if ") == 0) {
			elem.outerHTML = "<span id='typecode" + idstep + "' class='textStyle'>if&nbsp;</span><input type='hidden' id='inputcodehidden" + idstep + "' value='if '/><input size='100%'  maxlength='500' spellcheck='false' draggable=\"false\" id='inputcode" + idstep + "' type='text' value='" + oldname.replace("if ","").split("'").join("&apos;") + "' onblur='modifcode(this, " + idstep + " , \"out\");'/>";
			} else {
			if (oldname.indexOf("for ") == 0) {
				elem.outerHTML = "<span id='typecode" + idstep + "' class='textStyle'>for&nbsp;</span><input type='hidden' id='inputcodehidden" + idstep + "' value='for '/><input size='100%'  maxlength='500' spellcheck='false' draggable=\"false\" id='inputcode" + idstep + "' type='text' value='" + oldname.replace("for ","").split("'").join("&apos;") + "' onblur='modifcode(this, " + idstep + " , \"out\", " + validcode + ");'/>";
			} else {
				if (oldname.indexOf("end while ") == 0) {
					elem.outerHTML = "<span id='typecode" + idstep + "' class='textStyle'>end while&nbsp;</span><input type='hidden' id='inputcodehidden" + idstep + "' value='end while '/><input size='100%' maxlength='500' spellcheck='false' draggable=\"false\" id='inputcode" + idstep + "' type='text' value='" + oldname.replace("end while ","").split("'").join("&apos;") + "' onblur='modifcode(this, " + idstep + " , \"out\", " + validcode + ");'/>";
				} else {
					if (oldname.indexOf("end until ") == 0) {
						elem.outerHTML = "<span id='typecode" + idstep + "' class='textStyle'>end until&nbsp;</span><input type='hidden' id='inputcodehidden" + idstep + "' value='end until '/><input size='100%' maxlength='500' spellcheck='false' draggable=\"false\" id='inputcode" + idstep + "' type='text' value='" + oldname.replace("end until ","").split("'").join("&apos;") + "' onblur='modifcode(this, " + idstep + " , \"out\", " + validcode + ");'/>";
					} else {
						if (elem.getAttribute("tempo") == "true") {
							elem.outerHTML = "<span tempo='true' id='typecode" + idstep + "' class='textStyle'></span><input type='hidden' id='inputcodehidden" + idstep + "' value=''/><textarea cols='70' rows='3' tempo='true' spellcheck='false' draggable=\"false\" id='inputcode" + idstep + "' type='text' onblur='modifcode(this, " + idstep + " , \"out\", " + validcode + ");'>" + oldname.split("'").join("&apos;") + "</textarea>";
						} else {
							elem.outerHTML = "<span id='typecode" + idstep + "' class='textStyle'></span><input type='hidden' id='inputcodehidden" + idstep + "' value=''/><input size='100%'  maxlength='500' spellcheck='false' draggable=\"false\" id='inputcode" + idstep + "' type='text' value='" + oldname.split("'").join("&apos;") + "' onblur='modifcode(this, " + idstep + " , \"out\", " + validcode + ");'/>";
						}
					}
				}
			}
		}

        document.getElementById("inputcode" + idstep).focus();
    } else {
        if (document.getElementById("inputcode" + idstep) != null && out == 'out') {
            newname = document.getElementById("inputcodehidden" + idstep).value + document.getElementById("inputcode" + idstep).value;
            document.getElementById("hiddeninitcode" + idstep).value = newname;
            elem.outerHTML = "<span class=\"textStyle\" tempo=\"" + elem.getAttribute("tempo") + "\" onclick=\"modifcode(this, " + idstep + " , 'in', " + validcode + ");\">" + newname.replace(/</g,"&lt;").replace(/\n/g, "<br>") + "</span>";
			document.getElementById("typecode" + idstep).outerHTML = "";
            document.getElementById('divstepseq' + sequence).setAttribute("draggable", true);
            document.getElementById("chgtpval_params").value = newname;
            document.getElementById("chgtpval_stepid").value = idstep;
            document.getElementById("formchangeparamvalue").submit();
        }
    }
}




function onloadiframeaddstep() {
	addi = 0;
	code = document.getElementById("hiddenFrame").contentDocument.body.innerHTML;
    if (document.getElementById("hiddenFrame").contentDocument.body.innerHTML == 'KO') {
        document.getElementById('objpopup').contentDocument.getElementById('message').innerHTML = "<span class='errorMessage' onclick='this.parentNode.removeChild(this)'  style='vertical-align: top;'>" + erreur_msg + "<b>&nbsp;&nbsp;&nbsp;&nbsp;x</b></span>";
    } else {
        if (document.getElementById("hiddenFrame").contentDocument.body.innerHTML != '') {
            if (document.getElementById('objpopup')) {document.getElementById('objpopup').contentDocument.getElementById('message').innerHTML = "<span class='succesMessage' onclick='this.parentNode.removeChild(this)'  style='vertical-align: top;'>" + proc_ajoutee_msg + "<b>&nbsp;&nbsp;&nbsp;&nbsp;x</b></span>";}
			if (document.getElementById(document.getElementById('afterstepnew').value)) {
				elems = document.getElementById("hiddenFrame").contentDocument.getElementsByName("divstep");
				addi = elems.length;
				n_start = parseInt(document.getElementById("hiddenFrame").contentDocument.body.children[0].id.replace("divstepseq",""));
				var n = n_start;
				while (document.getElementById("divstepseq" + n)) {n++;}
				 n = n-1;
				for (i=n;i>=n_start;i--) {
					document.getElementById("divstepseq" + i).id = "divstepseq" + (i+addi);
					document.getElementById("divstepseq" + (i+addi)).setAttribute("title", (i+addi));
				}
				
				//document.getElementById(document.getElementById('afterstepnew').value).outerHTML = document.getElementById(document.getElementById('afterstepnew').value).outerHTML + "<div id='divnewstep'></div>";
				var newdiv = document.createElement("div");
				newdiv.setAttribute("id", 'divnewstep');
				appendAfter(newdiv, document.getElementById(document.getElementById('afterstepnew').value));
				//document.getElementById(document.getElementById('afterstepnew').value).insertAfter(newdiv);
				document.getElementById("divnewstep").outerHTML = code;
				selectTestStep(document.getElementById(document.getElementById("hiddenFrame").contentDocument.body.children[0].id));
			} else {
				document.getElementById("steps").innerHTML += code;
				selectTestStep(document.getElementById(document.getElementById("hiddenFrame").contentDocument.body.children[0].id));
				elems = document.getElementById("hiddenFrame").contentDocument.getElementsByName("divstep");
				addi = elems.length;
			}
        }
    }
	if (code.indexOf("validcode") >= 0) {
		if (document.getElementById("btnvalidstruct")) {document.getElementById("btnvalidstruct").style.display = "inline-block";}
		if (document.getElementById("btnlaunch")) {document.getElementById("btnlaunch").style.display = "none";}
		if (document.getElementById("btnreport")) {document.getElementById("btnreport").style.display = "none";}
	}
    stoploader();
}

function appendAfter(divToAppend, siblingBefore) {
    if(siblingBefore.nextSibling) {
        siblingBefore.parentNode.insertBefore(divToAppend, siblingBefore.nextSibling);
    } else {
        siblingBefore.parentNode.appendChild(divToAppend);
    }
}

function cibleStep(sheet_id, node_id) {
    if (document.getElementById('sheetinit').value == sheet_id) {
        elem = document.getElementById('maincadre' + node_id);
		if (elem) {
        document.getElementById('wrapper2').scrollTop = 0;
        document.getElementById('wrapper2').scrollLeft = 0;
        document.getElementById('wrapper1').scrollLeft = 0;
        cadre = elem.getBoundingClientRect();
        document.getElementById('wrapper2').scrollTop = cadre["top"] - document.getElementById('wrapper2').offsetTop - document.getElementById('wrapper2').offsetHeight / 2;
        document.getElementById('wrapper2').scrollLeft = cadre["left"] - document.getElementById('wrapper2').offsetLeft - document.getElementById('wrapper2').offsetWidth / 2;
        document.getElementById('wrapper1').scrollLeft = cadre["left"] - document.getElementById('wrapper2').offsetLeft - document.getElementById('wrapper2').offsetWidth / 2;
        elem.setAttribute('style', 'fill:blue');
        setTimeout(function () {
            elem.setAttribute('style', 'fill:url(#vertDegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
        }, 250);
		}
    } else {
        document.getElementById('idnodetocentre').value = node_id;
        document.getElementById('sheettoload').value = sheet_id;
        startloader();
        document.getElementById('formloadsheet').submit();
    }
}

function buildtestidstring(){
    var checkboxes = document.getElementsByName("chbxinput");
    teststring = "";
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) {
            teststring = teststring + "|" + checkboxes[i].id + "|";
        }
    }
    document.getElementById("testlist").value = teststring;
}


function morefolderoption(elem, folder_id) {

    elem.style.display = 'none';
    try {
        document.getElementById("btncopyf" + folder_id).style.display = "inline";
    } catch (e) {
    }
    try {
        document.getElementById("btndelf" + folder_id).style.display = "inline";
    } catch (e) {
    }
    try {
        document.getElementById("btncutf" + folder_id).style.display = "inline";
    } catch (e) {
    }
}




function copyTest(test_id) {
	if (document.getElementById("is_atdd")) {
		setCookie("atdd_test_or_folder_to_paste", "copy|test|" + test_id);
	} else {	
		setCookie("test_or_folder_to_paste", "copy|test|" + test_id);
	}	
    showpastebutton();
}
function cutTest(test_id) {
	if (document.getElementById("is_atdd")) {
		setCookie("atdd_test_or_folder_to_paste", "cut|test|" + test_id);
	} else {	
		setCookie("test_or_folder_to_paste", "cut|test|" + test_id);
	}
    showpastebutton();
}
function copyFolder(folder_id) {
	if (document.getElementById("is_atdd")) {
		setCookie("atdd_test_or_folder_to_paste", "copy|folder|" + folder_id);
	} else {	
		setCookie("test_or_folder_to_paste", "copy|folder|" + folder_id);
	}
    showpastebutton();
}
function cutFolder(folder_id) {
	if (document.getElementById("is_atdd")) {
		setCookie("atdd_test_or_folder_to_paste", "cut|folder|" + folder_id);
	} else {	
		setCookie("test_or_folder_to_paste", "cut|folder|" + folder_id);
	}
    showpastebutton();
}
function pasteelement(folder_id) {
    document.getElementById('folder_id_destination').value = folder_id;
	if (document.getElementById("is_atdd")) {
		document.getElementById('test_or_folder_to_paste').value = getCookie('atdd_test_or_folder_to_paste');
	} else {
		document.getElementById('test_or_folder_to_paste').value = getCookie('test_or_folder_to_paste');
	}
    setCookie('test_or_folder_to_paste', '');
	setCookie('atdd_test_or_folder_to_paste', '');
    document.getElementById('formpaste').submit();
    hidepastebutton();
}



function showpastebutton() {
    elements = document.getElementsByName('btnpaste');
    for (i = 0; i < elements.length; i++) {
        elements[i].style.display = 'inline';
    }
}

function hidepastebutton() {
    elements = document.getElementsByName('btnpaste');
    for (i = 0; i < elements.length; i++) {
        elements[i].style.display = 'none';
    }
}




function copystep(typetest) {
	if (typetest != "1") {typetest = "0";};
    var checkboxes = document.getElementsByName("chbxinput");
    stepstring = "";
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) {
            stepstring = stepstring + "|" + checkboxes[i].value + "|";
        }
    }
    if (stepstring != "") {
        setCookie("step_to_paste" + typetest, "copy|" + stepstring);
        showpasteafterbeforebutton();
    } else {
        setCookie("step_to_paste" + typetest, "");
        hidepasteafterbeforebutton();
    }
}

function cutstep(typetest) {
	if (typetest != "1") {typetest = "0";};
    var checkboxes = document.getElementsByName("chbxinput");
    stepstring = "";
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) {
            stepstring = stepstring + "|" + checkboxes[i].value + "|";
        }
    }
    if (stepstring != "") {
        setCookie("step_to_paste" + typetest, "cut|" + stepstring);
        showpasteafterbeforebutton();
    } else {
        setCookie("step_to_paste" + typetest, "");
        hidepasteafterbeforebutton();
    }
}

function hold_step(elem_id) {
	startloader();
	document.getElementById('btnhold' + elem_id).style.display = "none";
	document.getElementById('btndonthold' + elem_id).style.display = "inline";
	document.getElementById('divstepid' + elem_id).setAttribute('class', 'linestephold');
	document.getElementById("hold_step_id").value = elem_id;
	document.getElementById("formholdstep").submit();
}

function reactive_step(elem_id) {
	startloader();
	document.getElementById('btnhold' + elem_id).style.display = "inline";
	document.getElementById('btndonthold' + elem_id).style.display = "none";
	if (document.getElementById("is_atdd")) {
		document.getElementById('divstepid' + elem_id).setAttribute('class', 'linegherkin');
	} else {
		document.getElementById('divstepid' + elem_id).setAttribute('class', 'linestep');
	}
	document.getElementById("unhold_step_id").value = elem_id;
	document.getElementById("formunholdstep").submit();
}

function pastestep(where, elem_id) {
	test_kind = document.getElementById('test_kind').value;
	if (test_kind != "1") {test_kind = "0"};
	startloader();
    document.getElementById('paste_after_before').value = where;
    document.getElementById('paste_element_dest').value = elem_id;
    document.getElementById('step_to_paste').value = getCookie('step_to_paste' + test_kind);
    setCookie('step_to_paste' + test_kind, '');    
    document.getElementById('formpastestep').submit();
    hidepasteafterbeforebutton();
}

function insertcodeinstr(el, idstep) {
    startloader();
	var code = "";
	if (el.value) { code = el.value } else {code = el; };
    document.getElementById('code_id_condition_boucle').value=code;
	document.getElementById('idatddstep').value=idstep;
    document.getElementById('forminsertscodeinstr').submit();
}

function showpasteafterbeforebutton() {
    showpastebtn = false;
    elements = document.getElementsByName('btnpastebefore');
    if (elements.length>0) {
        showpastebtn = true;
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'inline';
        }
    }
    elements = document.getElementsByName('btnpasteafter');
    if (elements.length>0) {
        showpastebtn = true;
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'inline';
        }
    }
    elements = document.getElementsByName('btnpaste');
    if (elements.length>0 && showpastebtn == false) {
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'inline';
        }
    }
}

function hidepasteafterbeforebutton() {
    elements = document.getElementsByName('btnpaste');
    if (elements != null) {
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'none';
        }
    }
    elements = document.getElementsByName('btnpasteafter');
    if (elements != null) {
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'none';
        }
    }
    elements = document.getElementsByName('btnpastebefore');
    if (elements != null) {
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'none';
        }
    }
}


function selectTestStep(elem) {
    //styleElem = "background-color: green; border-style: solid; border-color: green;padding:5px 5px 5px 5px;";
    allelems = document.getElementsByName("divstep");
    for (i = 0; i < allelems.length; i++) {
		allelems[i].children[0].style.border = "solid 1px black";
    }

    if (elem) {
            //elem.children[0].style = styleElem ; 
			elem.children[0].style.border = "solid 5px";
			elem.children[0].style.borderColor = "#b20c25";
            //topPos = elem.offsetTop;
            //document.getElementById('left').scrollTop = (topPos - document.getElementById('left').offsetTop);
			document.getElementById('afterstepnew').value = elem.id;
			document.getElementById('aftercodenew').value = elem.id;
    }
}


function onloadiframevalidstruct() {
	if (document.getElementById("hiddenFrameValStr").contentDocument.body.innerHTML != "") {
		if (document.getElementById("messagevalide") && document.getElementById("hiddenFrameValStr").contentDocument.body) {
			document.getElementById("messagevalide").innerHTML = document.getElementById("hiddenFrameValStr").contentDocument.body.innerHTML;
			if (document.getElementById("messagevalide").innerHTML.indexOf("errorMessage") > 0) {
				document.getElementById("btnvalidstruct").style.display = "inline-block";
				document.getElementById("btnlaunch").style.display = "none";
				document.getElementById("btnreport").style.display = "none";
			} else {
				document.getElementById("btnvalidstruct").style.display = "none";
				document.getElementById("btnlaunch").style.display = "inline-block";
				document.getElementById("btnreport").style.display = "inline-block";
			}
		}
	}
}


function commenttododone(step_id) {
	document.getElementById('steptododone').value = step_id;
	document.getElementById('formtododone').submit();
	document.getElementById('divstepid' + step_id).setAttribute("class", "linecomment");
	document.getElementById('btnvalid' + step_id).parentNode.removeChild(document.getElementById('btnvalid' + step_id));
}

function zonefiltre(bool) {
	if (bool == true) {
		document.getElementById('btnfiltre').style.display = "none";
		document.getElementById('btnnofiltre').style.display = "inline";
		document.getElementById('zonefiltre').style.display = "block";
	} else {
		document.getElementById('btnfiltre').style.display = "inline";
		document.getElementById('btnnofiltre').style.display = "none";
		document.getElementById('zonefiltre').style.display = "none";
		document.getElementById('fcomment').checked = true;
		document.getElementById('ftodo').checked = true;
		document.getElementById('fcode').checked = true;
		document.getElementById('fproc').checked = true;
		document.getElementById('fval').value = "";
		divsteps = document.getElementsByName("divstep");
		for (i = 0; i < divsteps.length; i++) {
			divsteps[i].style.display = "inline";
		}
	}
}

function filtrertestsepstext(el) {
	fcommentchecked = document.getElementById('fcomment').checked;
	ftodochecked = document.getElementById('ftodo').checked;
	fcodechecked = document.getElementById('fcode').checked;
	fprocchecked = document.getElementById('fproc').checked;
	divsteps = document.getElementsByName("divstep");
	if (el.value != "") {
		for (i = 0; i < divsteps.length; i++) {
			if (divsteps[i].innerText.indexOf(el.value) >= 0) {
				divsteps[i].style.display = "inline";
			} else {
				divsteps[i].style.display = "none";
			}
		}	
	} else {
		for (i = 0; i < divsteps.length; i++) {
			step_type = divsteps[i].children[0].className;
			if (step_type == "linecomment") {
				if (fcommentchecked) {
					divsteps[i].style.display = "inline"; 
				} else {
					divsteps[i].style.display = "none"; 
				}	
			}
			if (step_type == "linecommenttodo") {
				if (ftodochecked) {
					divsteps[i].style.display = "inline"; 
				} else {
					divsteps[i].style.display = "none"; 
				}	
			}
			if (step_type == "linecondition") {
				if (fcodechecked) {
					divsteps[i].style.display = "inline"; 
				} else {
					divsteps[i].style.display = "none"; 
				}	
			}
			if (step_type == "linestep" || step_type == "linestephold") {
				if (fprocchecked) {
					divsteps[i].style.display = "inline"; 
				} else {
					divsteps[i].style.display = "none"; 
				}	
			}
		}	
	}
}

function filtrertestseps(el) {
	if (el.checked) {
		divsteps = document.getElementsByName("divstep");
		for (i = 0; i < divsteps.length; i++) {
			if (el.id == 'fcomment') {
				step_type = divsteps[i].children[0].className;
				if (step_type == "linecomment") {
					divsteps[i].style.display = "inline";
				}
			}
			if (el.id == 'ftodo') {
				step_type = divsteps[i].children[0].className;
				if (step_type == "linecommenttodo") {
					divsteps[i].style.display = "inline";
				}
			}
			if (el.id == 'fcode') {
				step_type = divsteps[i].children[0].className;
				if (step_type == "linecondition") {
					divsteps[i].style.display = "inline";
				}
			}
			if (el.id == 'fproc') {
				step_type = divsteps[i].children[0].className;
				if (step_type == "linestep" || step_type == "linestephold") {
					divsteps[i].style.display = "inline";
				}
			}
		}	
	} else {
		divsteps = document.getElementsByName("divstep");
		for (i = 0; i < divsteps.length; i++) {
			if (el.id == 'fcomment') {
				step_type = divsteps[i].children[0].className;
				if (step_type == "linecomment") {
					divsteps[i].style.display = "none";
				}
			}
			if (el.id == 'ftodo') {
				step_type = divsteps[i].children[0].className;
				if (step_type == "linecommenttodo") {
					divsteps[i].style.display = "none";
				}
			}
			if (el.id == 'fcode') {
				step_type = divsteps[i].children[0].className;
				if (step_type == "linecondition") {
					divsteps[i].style.display = "none";
				}
			}
			if (el.id == 'fproc') {
				step_type = divsteps[i].children[0].className;
				if (step_type == "linestep" || step_type == "linestephold") {
					divsteps[i].style.display = "none";
				}
			}
		}	
	}
}

function foldcomment(el) {
	if (el.getAttribute("comm-fold") == "false"){
		el.setAttribute("comm-fold","true");
		divfolds = document.getElementsByName("foldunflod");
		for (nd = 0; nd < divfolds.length; nd++) {
			filtrestepundercomment(divfolds[nd], true);
		}
	} else {
		el.setAttribute("comm-fold","false");
		divfolds = document.getElementsByName("foldunflod");
		for (nd = 0; nd < divfolds.length; nd++) {
			filtrestepundercomment(divfolds[nd], false);
		}
		
	}
}

function filtrestepundercomment(el, force) {
	if ((el.innerHTML == "<b>-</b>" && force == null) || force == true) {
		el.innerHTML = "<b>+</b>";
		el = el.parentNode.parentNode;
		commentnext = null;
		comments = document.getElementsByName("linecomment");
		findnext = false;
		for (i=0;i<comments.length;i++) {
			if (findnext && commentnext == null) {commentnext = comments[i]; break;}
			if (comments[i]==el) {findnext = true;}
		}
		starthide = el.parentNode.offsetTop;
		if (commentnext != null) {
			stophide = commentnext.parentNode.offsetTop;
		} else {
			stophide = 9999999999;
		}
		steps = document.getElementsByName("divstep"); 
		var hidels = [];
		for (i=0;i<steps.length;i++) {
			if ((stophide - steps[i].offsetTop)>0 && (steps[i].offsetTop - starthide)>0) {
				hidels.push(steps[i]);
			}
		}
		for (i=0;i<hidels.length;i++) {
			hidels[i].style.display="none";
			hidels[i].setAttribute("hidecomm", el.id);
		}

	} else {
		if (el.innerHTML == "<b>+</b>") {
			el.innerHTML = "<b>-</b>";
			elid = el.parentNode.parentNode.id;
			steps = document.getElementsByName("divstep"); 
			for (i=0;i<steps.length;i++) {
				if (steps[i].getAttribute("hidecomm")) {
					if (steps[i].getAttribute("hidecomm")==elid) {
						steps[i].style.display="block";
						steps[i].setAttribute("hidecomm",null);
					}
				}
			}

		}	
	}
}

function setprocidoratddidsearch() {
	document.getElementById('proc_id').value = "-";
	myoptions = document.getElementById('procs').options;
	valeur = document.getElementById('inputprocs').value;
	for (i=0;i<myoptions.length;i++) {
		if (myoptions[i].value == valeur) {
			document.getElementById('proc_id').value = myoptions[i].id;
			break;
		}
	}
	document.getElementById('fatdd_id').value = "-";
	myoptions = document.getElementById('latdds').options;
	valeur = document.getElementById('inputlatdds').value;
	for (i=0;i<myoptions.length;i++) {
		if (myoptions[i].value == valeur) {
			document.getElementById('fatdd_id').value = myoptions[i].id;
			break;
		}
	}
}


function setrempatddidsearch() {
	document.getElementById('rempatdd_id').value = "-";
	myoptions = document.getElementById('remplatdds').options;
	valeur = document.getElementById('inputremplatdds').value;
	for (i=0;i<myoptions.length;i++) {
		if (myoptions[i].value == valeur) {
			document.getElementById('rempatdd_id').value = myoptions[i].id;
			break;
		}
	}
}

function setrempprocidsearch() {
	document.getElementById('rempproc_id').value = "-";
	myoptions = document.getElementById('rempprocs').options;
	valeur = document.getElementById('inputrempprocs').value;
	for (i=0;i<myoptions.length;i++) {
		if (myoptions[i].value == valeur) {
			document.getElementById('rempproc_id').value = myoptions[i].id;
			break;
		}
	}
}

function superposeprocfilter() {
	if (document.getElementById("filter")) {
		document.getElementById("filter").style.width = (document.getElementById("proc_id").offsetWidth-20)  + "px";
		document.getElementById("filter").style.marginLeft = "-" + (document.getElementById("proc_id").offsetWidth-1) + "px";
		if (document.getElementById("proc_id").value.split('|$|')[1]) {
			document.getElementById("filter").value = document.getElementById("proc_id").value.split('|$|')[1];
		}
	}
	
	if (document.getElementById("remp_filter")) {
		document.getElementById("remp_filter").style.width = (document.getElementById("remp_proc_id").offsetWidth-20)  + "px";
		document.getElementById("remp_filter").style.marginLeft = "-" + (document.getElementById("remp_proc_id").offsetWidth-1) + "px";
		if (document.getElementById("remp_proc_id").value.split('|$|')[1]) {
			document.getElementById("remp_filter").value = document.getElementById("remp_proc_id").value.split('|$|')[1];
		}
	}
}

function filterproc() {
	
    var keyword = document.getElementById("filter").value;
    var selectproc = document.getElementById("proc_id");
	var nbshow = 0;
	var lastval = "";
	var lasttxt = "";
    for (var i = 0; i < selectproc.length; i++) {
        var txt = selectproc.options[i].text;
        if (txt.toLowerCase().indexOf(keyword.toLowerCase())<0) {
          $(selectproc.options[i]).attr('disabled', 'disabled').hide();
        } else {
          $(selectproc.options[i]).removeAttr('disabled').show();
		  nbshow += 1;
		  lasttxt = txt;
		  lastval = selectproc.options[i].value;
        }
    }
	if (nbshow == 1) {
		document.getElementById("filter").value = lasttxt;
		selectproc.value = lastval;
	}
}

function filterrempproc() {
    var keyword = document.getElementById("remp_filter").value;
    var selectproc = document.getElementById("remp_proc_id");
	var nbshow = 0;
	var lastval = "";
	var lasttxt = "";
    for (var i = 0; i < selectproc.length; i++) {
        var txt = selectproc.options[i].text;
        if (txt.toLowerCase().indexOf(keyword.toLowerCase())<0) {
          $(selectproc.options[i]).attr('disabled', 'disabled').hide();
        } else {
          $(selectproc.options[i]).removeAttr('disabled').show();
		  nbshow += 1;
		  lasttxt = txt;
		  lastval = selectproc.options[i].value;
        }
    }
	if (nbshow == 1) {
		document.getElementById("remp_filter").value = lasttxt;
		selectproc.value = lastval;
		showvalidbtn();
	}
}

function setVarInFiel(texte) {
  field.value = texte;
  field.focus();
  }