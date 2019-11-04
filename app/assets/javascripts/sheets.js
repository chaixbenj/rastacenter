/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


function showSheetHideSons(element, type) {
    repertoireDiplayed = localStorage.getItem("alfyft" + type + "repertoiredisplayed");
	if (repertoireDiplayed == null) {localStorage.setItem("alfyft" + type + "repertoiredisplayed","");repertoireDiplayed = localStorage.getItem("alfyft" + type + "repertoiredisplayed");}
    deplie = document.getElementById("signe" + element).innerHTML;
    if (deplie == "<b>+&nbsp;&nbsp;</b>") {
        elements = document.getElementsByName(element);
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'block';
        }
        document.getElementById("signe" + element).innerHTML = "<b>-&nbsp;&nbsp;</b>";
        repertoireDiplayed = repertoireDiplayed.replace("$" + element + "$", "");
        repertoireDiplayed += "$" + element + "$";
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
    localStorage.setItem("alfyft" + type + "repertoiredisplayed", repertoireDiplayed);
}

function addSubSheetFolder(idfolder, parent, type) {
    repertoireDiplayed = localStorage.getItem("alfyft" + type + "repertoiredisplayed")
	if (repertoireDiplayed == null) {localStorage.setItem("alfyft" + type + "repertoiredisplayed","");repertoireDiplayed = localStorage.getItem("alfyft" + type + "repertoiredisplayed");}
	repertoireDiplayed = repertoireDiplayed.replace("$" + parent + "$", "");
    repertoireDiplayed += "$" + parent + "$";
    localStorage.setItem("alfyft" + type + "repertoiredisplayed", repertoireDiplayed);
    document.getElementById("affolder").value = idfolder;
    startloader();
    document.getElementById("formadd_folder").submit();
}

function renameSheetFolder(idfolder) {
    oldname = document.getElementById("hidoln" + idfolder).value;
    if (document.getElementById("inputtext" + idfolder) == null) {
        document.getElementById("span" + idfolder).innerHTML = "<input id='inputtext" + idfolder + "' type='text' maxlength='250' value='" + oldname + "' onblur='document.getElementById(\"rfolder\").value=\"" + idfolder + "\";document.getElementById(\"rfoldername\").value=this.value;renameDBSheetFolder(" + idfolder + ");revertInputToText(" + idfolder + ")'/>";
        document.getElementById("inputtext" + idfolder).required = true;
        document.getElementById("inputtext" + idfolder).focus();
    }
}

function renameDBSheetFolder(idfolder) {
    if (document.getElementById("inputtext" + idfolder).value != "") {
        if (document.getElementById("inputtext" + idfolder).value != document.getElementById("hidoln" + idfolder).value) {
			document.getElementById("formrenamefolder").submit();
        }
    }
}


function revertInputToText(idfolder) {
    newname = document.getElementById("inputtext" + idfolder).value;
    if (newname == "") {
        newname = document.getElementById("hidoln" + idfolder).value;
    }
    document.getElementById("hidoln" + idfolder).value = newname;
    document.getElementById("span" + idfolder).innerHTML = "<span>" + newname + "</span>";
}


function addSheet(idfolder, parent, type) {
    repertoireDiplayed = localStorage.getItem("alfyft" + type + "repertoiredisplayed");
	if (repertoireDiplayed == null) {localStorage.setItem("alfyft" + type + "repertoiredisplayed","");repertoireDiplayed = localStorage.getItem("alfyft" + type + "repertoiredisplayed");}
    repertoireDiplayed = repertoireDiplayed.replace("$" + parent + "$", "");
	repertoireDiplayed += "$" + parent + "$";
    localStorage.setItem("alfyft" + type + "repertoiredisplayed", repertoireDiplayed);
    document.getElementById("asfolder").value = idfolder;
    startloader();
    document.getElementById("formadd_sheet").submit();
}

function renameSheet(idsheet) {
    oldname = document.getElementById("hidoltn" + idsheet).value;
    if (document.getElementById("inputtextsheet" + idsheet) == null) {
        document.getElementById("spant" + idsheet).innerHTML = "<input id='inputtextsheet" + idsheet + "' type='text' maxlength='250' value='" + oldname + "' onblur='document.getElementById(\"rsheet\").value=\"" + idsheet + "\";document.getElementById(\"rsheetname\").value=this.value;renameDBSheet(" + idsheet + ");revertInputSheetToText(" + idsheet + ")'/>";
        document.getElementById("inputtextsheet" + idsheet).required = true;
        document.getElementById("inputtextsheet" + idsheet).focus();
    }
}

function renameDBSheet(idsheet) {
    if (document.getElementById("inputtextsheet" + idsheet).value != "") {
        if (document.getElementById("inputtextsheet" + idsheet).value != document.getElementById("hidoltn" + idsheet).value) {
            document.getElementById("formrenamesheet").submit();
            if (document.getElementById("sname") != null) {
                document.getElementById("sname").value = document.getElementById("inputtextsheet" + idsheet).value;
            }            
        }
    }
}


function revertInputSheetToText(idsheet) {
    newname = document.getElementById("inputtextsheet" + idsheet).value;
    if (newname == "") {
        newname = document.getElementById("hidoltn" + idsheet).value;
    }
    document.getElementById("hidoltn" + idsheet).value = newname;
    document.getElementById("spant" + idsheet).innerHTML = "<span>" + newname + "</span>";
}


function deleteSheetFolder(idfolder) {
    if (confirm(supprimer_dossier_msg)) {
        element = document.getElementById("span" + idfolder);
        element.parentNode.parentNode.removeChild(element.parentNode);
        document.getElementById("idtodel").value = idfolder;
        document.getElementById("delwhat").value = "folder";
		document.getElementById("formdelete").submit();
    }
}


function deleteSheet(idsheet) {
    if (confirm(supprimer_sheet_msg)) {
        element = document.getElementById("spant" + idsheet).parentNode;
        element.parentNode.parentNode.removeChild(element.parentNode);
        document.getElementById("idtodel").value = idsheet;
        document.getElementById("delwhat").value = "sheet";
        document.getElementById("formdelete").submit();
        if (document.getElementById("sheetdetail")) {document.getElementById("sheetdetail").style.display = 'none';};
    }
}


function showSheet(sheetid) {
    document.getElementById("sheettoshow").value = sheetid;
    startloader();
    document.getElementById("formsheetindex").submit();
}






function copySheet(test_id, type) {
    setCookie(type + "sheet_or_folder_to_paste", "copy|sheet|" + test_id);
    showsheetpastebutton();
}
function duplicateSheet(test_id, type) {
    setCookie(type + "sheet_or_folder_to_paste", "duplicate|sheet|" + test_id);
    showsheetpastebutton();
}
function cutSheet(test_id, type) {
    setCookie(type + "sheet_or_folder_to_paste", "cut|sheet|" + test_id);
    showsheetpastebutton();
}
function cutSheetFolder(folder_id, type) {
    setCookie(type + "sheet_or_folder_to_paste", "cut|folder|" + folder_id);
    showsheetpastebutton();
}
function pastesheetelement(folder_id, type) {
    document.getElementById('folder_id_destination').value = folder_id;
    document.getElementById('sheet_or_folder_to_paste').value = getCookie(type + 'sheet_or_folder_to_paste');
    setCookie(type + 'sheet_or_folder_to_paste', '');
    document.getElementById('formpaste').submit();
    hidesheetpastebutton();
}



function showsheetpastebutton() {
    elements = document.getElementsByName('btnpaste');
    for (i = 0; i < elements.length; i++) {
        elements[i].style.display = 'inline';
    }
}

function hidesheetpastebutton() {
    elements = document.getElementsByName('btnpaste');
    for (i = 0; i < elements.length; i++) {
        elements[i].style.display = 'none';
    }
}


function selecttesttoaddsuite(el, idtest, testname, test_type) {
    alltests = document.getElementsByName('testitem');
    for (i=0;i<alltests.length;i++) {
		alltests[i].style.border = "solid 1px black";
       }
	//el.style.backgroundColor = "#b20c25";
	el.style.border = "solid 5px";
	el.style.borderColor = "#b20c25";
    document.getElementById("objtypetoadd").value = 'testinsuite';
    document.getElementById("objToLink").value = idtest + '||*$*||' + testname + '||*$*||' + test_type;
}



function showTestInSuiteHideSons(element) {
    repertoireDiplayed = localStorage.getItem("alfyfttestinsuiterepertoiredisplayed");
	if (repertoireDiplayed == null) {localStorage.setItem("alfyfttestinsuiterepertoiredisplayed","");repertoireDiplayed = localStorage.getItem("alfyfttestinsuiterepertoiredisplayed");}
    deplie = document.getElementById("signe" + element).innerHTML;
    if (deplie == "<b>+&nbsp;&nbsp;</b>") {
        elements = document.getElementsByName(element);
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'block';
        }
        document.getElementById("signe" + element).innerHTML = "<b>-&nbsp;&nbsp;</b>";
        repertoireDiplayed = repertoireDiplayed.replace("$" + element + "$", "");
        repertoireDiplayed += "$" + element + "$";
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
    localStorage.setItem("alfyfttestinsuiterepertoiredisplayed", repertoireDiplayed);
}

function settestidsearch() {
	document.getElementById('test_id').value = "-";
	myoptions = document.getElementById('tests').options;
	valeur = document.getElementById('inputtests').value;
	for (i=0;i<myoptions.length;i++) {
		if (myoptions[i].value == valeur) {
			document.getElementById('test_id').value = myoptions[i].id;
			break;
		}
	}
}


function superposetestfilter() {
	if (document.getElementById("filter")) {
		document.getElementById("filter").style.width = (document.getElementById("test_id").offsetWidth-20)  + "px";
		document.getElementById("filter").style.marginLeft = "-" + (document.getElementById("test_id").offsetWidth-1) + "px";
		if (document.getElementById("test_id").value.split('|$|')[1]) {
			document.getElementById("filter").value = document.getElementById("test_id").value.split('|$|')[1];
		}
	}
}

function filtertest() {
	
    var keyword = document.getElementById("filter").value;
    var selectproc = document.getElementById("test_id");
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