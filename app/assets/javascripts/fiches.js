var dragged_type_fiche;
var destination_td;
var ucf = "";
var valcn = "";
var valct = "";
var valccl = "";
var valcobl = "";

function majfichedisplaymsg() {
	stoploader();
	response = document.getElementById("hiddenframemaj").contentDocument.body.innerHTML;
	res = response.split(";");
	if (res[0] == "majok") {
		document.getElementById("okmessage").innerHTML = res[1] + "&nbsp;<b>x</b>";
		document.getElementById("okmessage").style="display:block;";
	}
	if (res[0] == "majko") {
		document.getElementById("komessage").innerHTML = res[1] + "&nbsp;<b>x</b>";
		document.getElementById("komessage").style="display:block;";
	}
	if (response.indexOf("div") >= 0) {
		document.body.innerHTML = response;
		if (document.getElementById("editor1")) {
			document.getElementById("editor1").innerHTML = document.getElementById("divtextarea").value.replace("<","&lt;").replace(">","&gt;");
			var maxline = parseInt((document.body.clientHeight - 100) / 13);
			var editor1 = ace.edit("editor1", {
			theme: "ace/theme/tomorrow_night",
			mode: "ace/mode/gherkin",
			maxLines: maxline,
			minLines: 10,
			wrap: true,
			fontSize: 13,
			autoScrollEditorIntoView: true
			});
			editor1.setOptions({
				enableBasicAutocompletion: true,
				enableSnippets: false,
				enableLiveAutocompletion: true
			});
			var staticWordCompleter = {
			getCompletions: function(editor, session, pos, prefix, callback) {
				var wordList =  document.getElementById("autocomplete").innerHTML.split(";;;");
				callback(null, wordList.map(function(word) {
					return {
						caption: word,
						value: word,
						meta: "static"
					};
				}));
			}
			}
			editor1.completers = [staticWordCompleter]
		}
	};
}

function add_row() {
    cust_table = document.getElementById("fic_table_custo_field");
    nbrow += 1;
    var row = cust_table.insertRow(nbrow);
    rowinnerHTML = '<td border="2" bgcolor="#6FEF99" id="' + nbrow + '-1" draggable="true" ondragover="draggingTypeFicheOver(event, this)" ondrop="droppedTypeFiche(event, this);nextUCFdispo();">&nbsp;</td><td bgcolor="#6FEF99" id="' + nbrow + '-2"  draggable="true" ondragover="draggingTypeFicheOver(event, this)" ondrop="droppedTypeFiche(event, this);nextUCFdispo();">&nbsp;</td><td bgcolor="#6FEF99" id="' + nbrow + '-3"  draggable="true" ondragover="draggingTypeFicheOver(event, this)" ondrop="droppedTypeFiche(event, this);nextUCFdispo();">&nbsp;</td>';
    row.innerHTML = rowinnerHTML;
}

function active_choix_liste(val, idel) {
    if (val == 'list') {
        document.getElementById(idel).style.display = 'inline';
    } else {
        document.getElementById(idel).style.display = 'none';
    }
}

function nextUCFdispo() {
    var nextval = 0;
    for (i = 0; i < 50; i++) {
        if (document.getElementById("ucf" + i)) {
        } else {
            nextval = i;
            break;
        }
    }
    if (document.getElementById("nextuserfield")) {
        document.getElementById("nextuserfield").value = "ucf" + nextval;
    }

}






function dragTypeFicheStarted(evt, el) {
    dragged_type_fiche = el;
    evt.dataTransfer.setData("text/plain", dragged_type_fiche.innerHTML);
    evt.dataTransfer.effectAllowed = "move";
}


function draggingTypeFicheOver(evt, el) {
    evt.preventDefault();
    evt.dataTransfer.dropEffect = "move";
}

function droppedTypeFiche(evt, el) {
    destination_td = el;
    evt.preventDefault();
    evt.stopPropagation();
    posdepart = "" + dragged_type_fiche.id.replace("insertcustofield", "");
    posdestination = el.id;
    if (posdepart != posdestination) {
        var sons = dragged_type_fiche.children;
        for (var i = 0; i < sons.length; i++) {
            if (sons[i].getAttribute("role") == "ucf") {
                ucf = sons[i].value;
            }
            if (sons[i].getAttribute("role") == "cn") {
                valcn = sons[i].value;
            }
            if (sons[i].getAttribute("role") == "ct") {
                valct = sons[i].value;
            }
            if (sons[i].getAttribute("role") == "ccl") {
                valccl = sons[i].value;
            }
            if (sons[i].getAttribute("role") == "cobl") {
                valcobl = sons[i].value;
            }
        }
        newdiv = dragged_type_fiche.cloneNode(true);
        var sons = newdiv.children;
        newdiv.id = "insertcustofield" + posdestination;
        newdiv.setAttribute("name", "insertcustofield" + posdestination);
        for (var i = 0; i < sons.length; i++) {
            if (posdepart == "") {
                sons[i].setAttribute("id", sons[i].id + posdestination);
                sons[i].setAttribute("name", sons[i].getAttribute("role") + posdestination);
                if (sons[i].getAttribute("role") == "ucf") {
                    sons[i].id = ucf;
                }
                if (sons[i].id.indexOf("btndel") == 0) {
                    sons[i].style.display = "inline-block";
                }
            } else {
                sons[i].setAttribute("id", sons[i].id.replace(posdepart, posdestination));
                if (sons[i].getAttribute("name")) {
                    sons[i].setAttribute("name", sons[i].getAttribute("name").replace(posdepart, posdestination));
                }
            }
            if (sons[i].getAttribute("role") == "ucf") {
                sons[i].value = ucf;
            }
            if (sons[i].getAttribute("role") == "ucfh") {
                sons[i].value = ucf;
            }
            if (sons[i].getAttribute("role") == "cn") {
                sons[i].value = valcn;
            }
            if (sons[i].getAttribute("role") == "ct") {
                sons[i].value = valct;
            }
            if (sons[i].getAttribute("role") == "ccl") {
                sons[i].value = valccl;
            }
            if (sons[i].getAttribute("role") == "cobl") {
                sons[i].value = valcobl;
            }
        }

        destination_td.appendChild(newdiv);
        if (posdepart != "") {
            dragged_type_fiche.parentNode.removeChild(dragged_type_fiche);
        }
    }
}



function dragSwitchStarted(evt) {
    source = evt.target;
    evt.dataTransfer.setData("text/plain", source.innerHTML);
    evt.dataTransfer.effectAllowed = "move";
}


function draggingSwitchOver(evt) {
    evt.preventDefault();
    evt.dataTransfer.dropEffect = "move";
}


function droppedSwitch(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    sourceHTML = source.outerHTML;
    destination = evt.target;
    reponse = "ok";
    if (!destination.id) {
        do {
            destination = destination.parentNode;
        } while (!destination.id)
    }
    if (destination.id) {
        if (destination.id != source.id) {
            if (source.id.indexOf("fiche-") == 0) {
				movefiche = true;
                newstatus = "";
                if (destination.id.indexOf("fiche-") == 0) {
                    newstatus = destination.parentNode.id.split("-")[1];
					groupby = destination.parentNode.id.split("-")[2];
					if (groupby != "id" && groupby != "user_cre") {
						groupid = destination.parentNode.id.split("-")[3];
					} else {
						groupid = "";
						if (groupby == "user_cre") {
							user_dest = destination.parentNode.id.replace("blocbacklog-" + newstatus + "-user_cre-", ""); 
							if (user_dest != source.getAttribute("groupe")) {movefiche = false;}
						}
					}
                }
                if (destination.id.indexOf("blocbacklog-") == 0) {
                    newstatus = destination.id.split("-")[1];
					groupby = destination.id.split("-")[2];
					if (groupby != "id" && groupby != "user_cre") {
						groupid = destination.id.split("-")[3];
					} else {
						groupid = "";
						if (groupby == "user_cre") {
							user_dest = destination.id.replace("blocbacklog-" + newstatus + "-user_cre-", ""); 
							if (user_dest != source.getAttribute("groupe")) {movefiche = false;}
						}
					}
                }
				if (movefiche) {
                idfiche = source.id.replace("fiche-", "");
                new_status_name = document.getElementById("value-" + newstatus).value;
				startloader();
                var xmlHttp = new XMLHttpRequest();
                xmlHttp.open("POST", "../fiches/move?moved_fiche=" + idfiche + "&new_status=" + newstatus + "&new_status_name=" + new_status_name  + "&groupby=" + groupby  + "&groupid=" + groupid, true);
                xmlHttp.setRequestHeader('X-CSRF-Token', document.getElementById("token").value);
                xmlHttp.onload = function (e) {
                    if (xmlHttp.readyState === 4) {
                        if (xmlHttp.status === 200) {
                            reponse = xmlHttp.responseText;
                            if (reponse == "ok") {
                                 if (destination.id.indexOf('blocbacklog') == 0) {
                                    targetHTML = destination.innerHTML;
                                    destination.innerHTML = targetHTML + sourceHTML;
                                } else {
                                    targetHTML = destination.outerHTML;
                                    destination.outerHTML = sourceHTML + targetHTML;
                                }
                                source.parentNode.removeChild(source);
								stoploader();
                            } else {
								if (reponse == "refresh") {
									localStorage.setItem('alfyftscrollkbn', document.getElementById("contentkanban").scrollTop);
									location.reload();
									stoploader();
								} else {
									stoploader();
									alert(xmlHttp.responseText);
								}
							}
                        } else {
							stoploader();
                            alert(xmlHttp.responseText);
                        }
                    }
                };
                xmlHttp.send(null);
				}
            } else {
                targetHTML = destination.outerHTML;
                destination.outerHTML = sourceHTML + targetHTML;
                source.parentNode.removeChild(source);
            }
			
        }
    }
}
var newcomment = 0;
function add_comment(el, who) {
	newcomment += 1;
    mydate = new Date(Date.now()).toLocaleString();
    commentbutton = el.outerHTML;
    commentbutton += ' <div style="display:block;width:100%;"> ';
    commentbutton += ' <span class="textStyle">' + who + ', ' + mydate + ' :</span><br>';
    commentbutton += ' <trix-editor id="trix_richarea_n' + newcomment + '" input="_richarea_n' + newcomment + '" style="background-color:white"></trix-editor>';
    commentbutton += ' <input type="hidden" id="_richarea_n' + newcomment + '" name="newcomm-' + newcomment + '"  value=""/></div>';
    commentbutton += ' <input type="hidden" name="newcommwho' + newcomment + '" value="' + who + '"/>';
    el.outerHTML = commentbutton;
}


function add_fiche_on_kanban(idel, name, status, user, color, groupby, idgroupe, testlink) {
	if (idgroupe == '') {
		cell = document.getElementById("blocbacklog-" + status + "-id");
	} else {
		cell = document.getElementById("blocbacklog-" + status + "-" + groupby + "-" + idgroupe);
	}
	if (cell) {
    contenu = cell.innerHTML;

    carte = "<div  id='fiche-" + idel + "' class='elemkanban' style='display:block;border-top-width:2px;border-top-color:" + color + ";border-left-width:2px;border-left-color:" + color + "' draggable='true' ondragstart='dragSwitchStarted(event);' ondragover='draggingSwitchOver(event);' ondrop='droppedSwitch(event);' groupe='" + idgroupe + "'>    ";
    carte += "<div class='ficheaddson' onclick='new_fiche(\"\", \"\", " + idel + ");' >+</div><div style='width:100%;'>";
    carte += "<span class='textStyle' style='color:#212326;' onclick='show_fiche(" + idel + ");' ><b>#" + idel + "</b></span></div>";
    carte += "<span class='textStyle' onclick='show_fiche(" + idel + ");' >" + name + "</span><br>";
    carte += "<span class='textStyle'>" + user + "</span><br>";
	if (testlink == 'redred') {carte += "<span class='pastillered' title='no run'> </span><span class='pastillered' title='no test'> </span><br>"}
	if (testlink == 'greenred') {carte += "<span class='pastillered' title='no run or last run fail'> </span><span class='pastillegreen' title='at least one test'> </span><br>"}
	if (testlink == 'greengreen') {carte += "<span class='pastillegreen' title='last run pass'> </span><span class='pastillegreen' title='at least one test'> </span><br>"}
    carte += "</div>";


    contenu += carte;
    cell.innerHTML = contenu;
	}
}

function showhisto() {
	if (document.getElementById('divhisto').style.display=='none') {
		document.getElementById('divhisto').style.display='block';
		document.getElementById('divjoinfiles').style.display='none';
		document.getElementById('divparents').style.display='none';
		document.getElementById('divtestlinked').style.display='none';
		document.getElementById('divtextarea').style.width='75%';
	} else {
		document.getElementById('divhisto').style.display='none';
		document.getElementById('divtextarea').style.width='100%';
	}
}

function showjoinfiles() {
	if (document.getElementById('divjoinfiles').style.display=='none') {
		document.getElementById('divjoinfiles').style.display='block';
		document.getElementById('divhisto').style.display='none';
		document.getElementById('divparents').style.display='none';
		document.getElementById('divtestlinked').style.display='none';
		document.getElementById('divtextarea').style.width='75%';
	} else {
		document.getElementById('divjoinfiles').style.display='none';
		document.getElementById('divtextarea').style.width='100%';
	}
}

function showparents() {
	if (document.getElementById('divparents').style.display=='none') {
		document.getElementById('divparents').style.display='block';
		document.getElementById('divhisto').style.display='none';
		document.getElementById('divjoinfiles').style.display='none';
		document.getElementById('divtestlinked').style.display='none';
		document.getElementById('divtextarea').style.width='75%';
	} else {
		document.getElementById('divparents').style.display='none';
		document.getElementById('divtextarea').style.width='100%';
	}
}

function showtestlinked() {
	if (document.getElementById('divtestlinked').style.display=='none') {
		document.getElementById('divparents').style.display='none';
		document.getElementById('divhisto').style.display='none';
		document.getElementById('divjoinfiles').style.display='none';
		document.getElementById('divtestlinked').style.display='block';
		document.getElementById('divtextarea').style.width='75%';
	} else {
		document.getElementById('divtestlinked').style.display='none';
		document.getElementById('divtextarea').style.width='100%';
	}
}

function loadattachement(attachment, fiche_id) {
    var file, xhr;
    file = attachment.files[0];
    xhr = new XMLHttpRequest;
    xhr.open("POST", "../fiches/uploadfile", true);
	xhr.setRequestHeader("X-CSRF-Token", document.getElementById("token").value);
	xhr.setRequestHeader("Content-Type", file.type);
	xhr.setRequestHeader("filename", file.name);
	xhr.setRequestHeader("fiche", fiche_id);
    xhr.onload = function() {
      var href, url;
      if (xhr.status === 200) {
		file = "../upload/" + xhr.responseText.split("||")[0] + xhr.responseText.split("||")[1];
		linkfile = "<br><div class='elemfiltreselected'><a href='" + file + "' download target=\"_blank\">" +  xhr.responseText.split("||")[1] + "</a>&nbsp;&nbsp;<b><span style='cursor:pointer' onclick=\"deljoinfile(this, '" + xhr.responseText.split("||")[0] + xhr.responseText.split("||")[1] + "', " + xhr.responseText.split("||")[2] + ")\">X</span></b></div>";
		if (xhr.responseText.split("||")[2] == '0') {
			document.getElementById("filesaddbeforsave").value += xhr.responseText.split("||")[0] + xhr.responseText.split("||")[1] + "||";
		}
        document.getElementById("updloadedfiles").innerHTML += linkfile;
      }
    };
    return xhr.send(file);
  }
  
function deljoinfile(e, fullfilename, fiche_id) {
	document.getElementById("deletefile").value = fullfilename;
	document.getElementById("deleteupload").submit();
	e.parentNode.parentNode.parentNode.removeChild(e.parentNode.parentNode);
	document.getElementById("filesaddbeforsave").value = document.getElementById("filesaddbeforsave").value.replace(fullfilename + "||", "");
}	

function deletefichefather() {
	startloader();
	document.getElementById("delp").value = "1";
	document.getElementById("fiche_form_id").submit();
}

function changeprojet() {
	document.getElementById("assigne_a").value="-";
	document.getElementById("cycle").value="-";
	document.getElementById("assigne_a").disabled=true;
	document.getElementById("cycle").disabled=true;
	
}

function get_filtered_fiche(str) {
	xhrgl = new XMLHttpRequest();
	startloader();
    xhrgl.open('GET', "../fiches/get_fiches_filtered?str=" + str, true);
    xhrgl.onreadystatechange = function () {
        if (xhrgl.readyState === 4) {
            //alert(xhr.responseText);
			if (xhrgl.responseText!="") {document.getElementById('addfs').innerHTML = xhrgl.responseText;}
			stoploader();
        }
    };
    xhrgl.send(null);
}


function getselectedfiche() {
var g = $('#inputaddfs').val();
var id = $('#addfs option[value="' + g +'"]').attr('id');
$('#addf').val(id);
if (id) { $('#adp').val('adp');$('#fiche_form_id').submit();}
}


