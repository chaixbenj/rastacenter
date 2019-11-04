/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

 function showHideCampain(element) {
	campaindisplayed = localStorage.getItem("alfyftcampaindisplayed");
	if (campaindisplayed == null) {localStorage.setItem("alfyftcampaindisplayed","");campaindisplayed = localStorage.getItem("alfyftcampaindisplayed");}
    deplie = document.getElementById("signe" + element).innerHTML;
    if (deplie == "<b>+&nbsp;&nbsp;</b>") {
        elements = document.getElementsByName(element);
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'inline-block';
        }
        document.getElementById("signe" + element).innerHTML = "<b>-&nbsp;&nbsp;</b>";
        campaindisplayed = campaindisplayed.replace("$" + element + "$", "");
        campaindisplayed += "$" + element + "$";
    } else {
        elements = document.getElementsByName(element);
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'none';
            try {
                fils = document.getElementsByName(elements[i].id);
                campaindisplayed = campaindisplayed.replace("$" + elements[i].id + "$", "");
                for (j = 0; j < fils.length; j++) {
                    document.getElementById("signe" + elements[i].id).innerHTML = "<b>+&nbsp;&nbsp;</b>";
                    fils[j].style.display = 'none';
                    try {
                        filsfils = document.getElementsByName(fils[j].id);
                        campaindisplayed = campaindisplayed.replace("$" + fils[j].id + "$", "");
                        for (k = 0; k < filsfils.length; k++) {
                            document.getElementById("signe" + fils[j].id).innerHTML = "<b>+&nbsp;&nbsp;</b>";
                            filsfils[k].style.display = 'none';
                        }
                    } catch(e) {}
                }
            } catch(e) {}
        }
        document.getElementById("signe" + element).innerHTML = "<b>+&nbsp;&nbsp;</b>";
		campaindisplayed = campaindisplayed.replace("$" + element + "$", "");
    }
    localStorage.setItem("alfyftcampaindisplayed", campaindisplayed);
}


function addcampainstep(elem_id) {
    startloader();
    document.getElementById('idsheetadded').value = elem_id;
    document.getElementById('formaddcampainstep').submit();
}


function droppedsuite(evt, elid) {
    evt.preventDefault();
    evt.stopPropagation();

    htmls = source.innerHTML;

    is = source.id.replace("divstepseq", "");
    id = elid.replace("divstepseq", "");
    document.getElementById("istart").value = is;
    document.getElementById("idest").value = id;
    startloader();
    document.getElementById("formreordercampainsteps").submit();
}



function deletecampainstep(idstep) {
    if (confirm(supprimer_suite_msg)) {
        document.getElementById("step_id").value = idstep;
        startloader();
	document.getElementById("formdeletecampainstep").submit();
    }
}

function onloadiframedeletereordercampain() {
    stoploader();
    result = document.getElementById("hiddenFrame2").contentDocument.body.innerHTML.split(';');
    if (result[0] == 'delete') {
            idstep = result[1];
            element = document.getElementById("divstepid" + idstep).parentNode;
            isup = element.id.replace("divstepseq", "");
            element.parentNode.removeChild(element);
            divsteps = document.getElementsByName("divstep");
            for (i = 0; i < divsteps.length; i++) {
                iseq = divsteps[i].id.replace("divstepseq", "");
                if (parseInt(iseq) > parseInt(isup)) {
                    divsteps[i].id = "divstepseq" + (parseInt(iseq) - 1);
                }
            }
    }
    if (result[0] == 'reorder') {
        is = result[1];
        id = result[2];
        elid = "divstepseq" + id;
        if (parseInt(is) < parseInt(id)) {
            for (i = parseInt(is) + 1; i <= parseInt(id); i++) {
                document.getElementById("divstepseq" + (i - 1)).innerHTML = document.getElementById("divstepseq" + i).innerHTML;
            }
            document.getElementById(elid).innerHTML = htmls;
        }

        if (parseInt(is) > parseInt(id)) {
            for (i = parseInt(is); i > parseInt(id); i--) {
                document.getElementById("divstepseq" + (i)).innerHTML = document.getElementById("divstepseq" + (i - 1)).innerHTML;
            }
            document.getElementById(elid).innerHTML = htmls;
        }
    }
}


function onloadiframeaddcampainstep() {
    stoploader();
    if (document.getElementById("hiddenFrame").contentDocument.body.innerHTML == 'KO') {
        document.getElementById('objpopup').contentDocument.getElementById('message').innerHTML = "<span class='errorMessage' onclick='this.parentNode.removeChild(this)'  style='vertical-align: top;'>" + erreur_msg + "<b>&nbsp;&nbsp;&nbsp;&nbsp;x</b></span>";
    } else {
        if (document.getElementById("hiddenFrame").contentDocument.body.innerHTML != '') {
            document.getElementById("steps").innerHTML += document.getElementById("hiddenFrame").contentDocument.body.innerHTML;
        }
    }
}



function copycampainstep() {
    var checkboxes = document.getElementsByName("chbxinput");
    testsuitestring = "";
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) {
            testsuitestring = testsuitestring + "|" + checkboxes[i].value + "|";
        }
    }
    if (testsuitestring != "") {
        setCookie("testsuite_to_paste", "copy|" + testsuitestring);
        showpasteafterbeforebutton();
    } else {
        setCookie("testsuite_to_paste", "");
        hidepasteafterbeforebutton();
    }
}

function cutcampainstep() {
    var checkboxes = document.getElementsByName("chbxinput");
    testsuitestring = "";
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) {
            testsuitestring = testsuitestring + "|" + checkboxes[i].value + "|";
        }
    }
    if (testsuitestring != "") {
        setCookie("testsuite_to_paste", "cut|" + testsuitestring);
        showpasteafterbeforebutton();
    } else {
        setCookie("testsuite_to_paste", "");
        hidepasteafterbeforebutton();
    }
}

function pastecampainstep(where, elem_id) {
    startloader();
    document.getElementById('paste_after_before').value = where;
    document.getElementById('paste_element_dest').value = elem_id;
    document.getElementById('testsuite_to_paste').value = getCookie('testsuite_to_paste');
    setCookie('testsuite_to_paste', '');    
    document.getElementById('formcampainpaste').submit();
    hidepasteafterbeforebutton();
}


function copycampain(campain_id) {
    setCookie("campain_to_paste", campain_id);
    showpastebutton();
}

function pastecampain(cycle_id) {
    document.getElementById('cycle_id_destination').value = cycle_id;
    document.getElementById('campain_to_paste').value = getCookie('campain_to_paste');
    setCookie('campain_to_paste', '');
    document.getElementById('formpaste').submit();
    hidepastebutton();
}

function computecovereeee() {
	repertoires = document.getElementsByClassName("treegroup");
   for (i=0;i<repertoires.length;i++) {
	rep_id = repertoires[i].id;
	npassrep = 0;
	nfailrep = 0;
	nnorunrep = 0;
	tests = document.getElementsByClassName("treegroupmore");

	for (j=0;j<tests.length;j++) {
		test_id = tests[j].id;
		if (test_id.indexOf(rep_id) == 0) {
			if (tests[j].getAttribute("npass")) {
			npassrep += parseInt(tests[j].getAttribute("npass"));}
			if (tests[j].getAttribute("nfailrep")) {
			nfailrep += parseInt(tests[j].getAttribute("nfail"));}
			if (parseInt(tests[j].getAttribute("nrun")) == 0) {
				nnorunrep += 1;
			}
		}
	}
	ntot = npassrep + nfailrep + nnorunrep;
	
	if (ntot > 0) {
		document.getElementById("pass" + rep_id).style.width = (npassrep / ntot) * 100 + "%";
		if (npassrep>0) {document.getElementById("pass" + rep_id).innerHTML = "<span style='float:right;margin-right:1px;color:white' ><b>" + npassrep + " </b></span>";}
		document.getElementById("fail" + rep_id).style.width = (nfailrep / ntot) * 100 + "%";
		if (nfailrep>0) {document.getElementById("fail" + rep_id).innerHTML = "<span style='float:right;margin-right:1px;color:white' ><b>" + nfailrep + " </b></span>";}
		document.getElementById("norun" + rep_id).style.width = (nnorunrep / ntot) * 100 + "%";
		if (nnorunrep>0) {document.getElementById("norun" + rep_id).innerHTML = "<span style='float:right;margin-right:1px;color:white' ><b>" + nnorunrep + " </b></span>";}
	}

	
   }
}




function computecover() {
   tests = document.getElementsByClassName("testmore");
   for (i=0;i<tests.length;i++) {
		npass = parseInt(tests[i].getAttribute("npass"));   
		nfail = parseInt(tests[i].getAttribute("nfail")); 
		nnorun = parseInt(tests[i].getAttribute("nnorun")); 
		nout = parseInt(tests[i].getAttribute("nout")); 
		
		testparentname = tests[i].getAttribute("name");
		ttestparentname = testparentname.split('-');
		rep_id = ttestparentname[0] + "-" + ttestparentname[1];
		for (j=2;j<ttestparentname.length;j++) {
			rep_id = rep_id + "-" + ttestparentname[j];
			rep = document.getElementById(rep_id);
			if (rep) {
				rep.setAttribute("npass", npass +  parseInt(rep.getAttribute("npass")));
				rep.setAttribute("nfail", nfail +  parseInt(rep.getAttribute("nfail")));
				rep.setAttribute("nnorun", nnorun +  parseInt(rep.getAttribute("nnorun")));
				rep.setAttribute("nout", nout +  parseInt(rep.getAttribute("nout")));
			}
		}
   }
   
   
   repertoires = document.getElementsByClassName("treegroup");
   for (i=0;i<repertoires.length;i++) {
		rep_id = repertoires[i].id;
		npass = parseInt(repertoires[i].getAttribute("npass"));   
		nfail = parseInt(repertoires[i].getAttribute("nfail")); 
		nnorun = parseInt(repertoires[i].getAttribute("nnorun")); 
		nout = parseInt(repertoires[i].getAttribute("nout")); 
		ntot = npass + nfail + nnorun + nout;
		if (ntot > 0) {
			document.getElementById("pass" + rep_id).style.width = (npass / ntot) * 100 + "%";
			if (npass>0) {document.getElementById("pass" + rep_id).innerHTML = "<span style='float:right;margin-right:2px;color:white' ><b>" + npass + " </b></span>";}
			document.getElementById("fail" + rep_id).style.width = (nfail / ntot) * 100 + "%";
			if (nfail>0) {document.getElementById("fail" + rep_id).innerHTML = "<span style='float:right;margin-right:2px;color:white' ><b>" + nfail + " </b></span>";}
			document.getElementById("nout" + rep_id).style.width = (nout / ntot) * 100 + "%";
			if (nout>0) {document.getElementById("nout" + rep_id).innerHTML = "<span style='float:right;margin-right:2px;color:white' ><b>" + nout + " </b></span>";}
			document.getElementById("norun" + rep_id).style.width = (nnorun / ntot) * 100 + "%";
			if (nnorun>0) {document.getElementById("norun" + rep_id).innerHTML = "<span style='float:right;margin-right:2px;color:white' ><b>" + nnorun + " </b></span>";}
		}
   }   

   repertoires = document.getElementsByClassName("treegroupmore");
   for (i=0;i<repertoires.length;i++) {
		rep_id = repertoires[i].id;
		npass = parseInt(repertoires[i].getAttribute("npass"));   
		nfail = parseInt(repertoires[i].getAttribute("nfail")); 
		nnorun = parseInt(repertoires[i].getAttribute("nnorun")); 
		nout = parseInt(repertoires[i].getAttribute("nout")); 
		ntot = npass + nfail + nnorun + nout;
		if (ntot > 0) {
			document.getElementById("pass" + rep_id).style.width = (npass / ntot) * 100 + "%";
			if (npass>0) {document.getElementById("pass" + rep_id).innerHTML = "<span style='float:right;margin-right:1px;color:white' ><b>" + npass + " </b></span>";}
			document.getElementById("fail" + rep_id).style.width = (nfail / ntot) * 100 + "%";
			if (nfail>0) {document.getElementById("fail" + rep_id).innerHTML = "<span style='float:right;margin-right:1px;color:white' ><b>" + nfail + " </b></span>";}
			document.getElementById("norun" + rep_id).style.width = (nnorun / ntot) * 100 + "%";
			if (nnorun>0) {document.getElementById("norun" + rep_id).innerHTML = "<span style='float:right;margin-right:1px;color:white' ><b>" + nnorun + " </b></span>";}
			document.getElementById("nout" + rep_id).style.width = (nout / ntot) * 100 + "%";
			if (nout>0) {document.getElementById("nout" + rep_id).innerHTML = "<span style='float:right;margin-right:1px;color:white' ><b>" + nout + " </b></span>";}
		}
   }   
   
}


function showwslauch(domaine, version) {
			if (document.getElementById("wssubmit").style.display == "none") {
			form = document.getElementById("fsubcp");
			payload = ":domaine_id => \"#{domaine}\",";
			payload += "<br>:version_id => \"" + version +"\"";
            for (var elem of form.elements) {
				if (elem.name == 'campain_id') {payload += ",<br>:submitcamp => \"" + elem.value +"\"";i++;};
				if (elem.name == 'modelaunch' && elem.checked == true) {payload += ",<br>:modelaunch => \"" + elem.value +"\"";i++;};
				if (elem.name.indexOf('chbxinput')>=0  && elem.checked == true) {payload += ",<br>:" + elem.name + " => \"" + elem.value +"\"";i++;};
				if (elem.name.indexOf('computer')>=0) {payload += ",<br>:" + elem.name + " => \"" + elem.value +"\"";i++;};
			}
			ws = "";
			ws = "require 'rest-client'\n";
			ws += "require 'json'\n\n";
			ws += "if File.exist?('./result')\n";
			ws += "	FileUtils.rm_r './result'\n";
			ws += "end\n";
			ws += "Dir.mkdir('./result') \n\n";

			ws += "#soumission de la campagne\n";
			ws += "user = 'user'\n";
			ws += "pwd = 'pwd'\n";
			ws += "domaine = \"" + domaine +"\"\n";
			ws += "payloadh = {" + payload + "}\n\n";
			ws += "payload = JSON.generate(payloadh)\n\n";
			ws += "rep = RestClient::Request.execute(\n";
			ws += "	:method => :post, \n";
			ws += "	:url => \"https://www.alfyftesting.fr/campains/wslaunch/\", \n";
			ws += "	:user => user, \n";
			ws += "	:password => pwd,\n";
			ws += "	:payload => payload,\n";
			ws += "	:headers => {:content_type => 'application/json'})\n\n";
			
			ws += "#attente fin de campagne et recupration resultats\n";	
			ws += "runs = rep.to_s.split(\";\")\n";
			ws += "if runs[0] == \"ok\"\n"; 
			ws += "	for i in 1..runs.length-1\n";
			ws += "		ended = \"\"\n";
			ws += "		begin\n";
			ws += "		rep = RestClient::Request.execute(\n";
			ws += "			:method => :get, \n";
			ws += "			:url => \"https://www.alfyftesting.fr/campains/wscampainresults?domaine_id=#{domaine}&id=#{runs[i]}\", \n";
			ws += "			:user => user, \n";
			ws += "			:password => pwd,\n";
			ws += "			:headers => {:content_type => 'application/json'})	\n";	
			ws += "			ended=rep[0..5]\n";
			ws += "			if ended == \"&lt;html&gt;\"\n";
			ws += "				freport = File.new(\"./result/report#{runs[i]}.html\", \"w+\")\n";
			ws += "				freport.puts rep \n";
			ws += "				freport.close\n";
			ws += "				puts \"end run #{runs[i]}\"\n";
			ws += "			else\n";
			ws += "				sleep 30\n";
			ws += "			end\n";
			ws += "		end while ended != \"&lt;html&gt;\"\n";
			ws += "	end\n";
			ws += "end\n";
			
			document.getElementById("editor1").innerHTML = ws;
            document.getElementById("wssubmit").style.display="block";
			var maxline = parseInt((document.body.clientHeight - 100) / 13);
			 var editor1 = ace.edit("editor1", {
				theme: "ace/theme/tomorrow_night",
				mode: "ace/mode/ruby",
				minLines: 10,
				maxLines: maxline,
				wrap: true,
				fontSize: 13,
				autoScrollEditorIntoView: true
			});
			editor1.setOptions({
				enableBasicAutocompletion: true,
				enableSnippets: true,
				enableLiveAutocompletion: false
			});
			} else {
				document.getElementById("wssubmit").style.display = "none";
			}
			}