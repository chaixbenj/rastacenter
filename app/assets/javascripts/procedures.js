function displayDOMelementParam(element, pindex) {
  divDomEl = element.parentNode;
  for (i=0;i<divDomEl.childNodes.length;i++) {
      if (divDomEl.childNodes[i].id == "toremove") {
          divDomEl.removeChild(divDomEl.childNodes[i]);
      }
  }
   
  matrixDomElemParameters = arraydomelemparam[pindex].split("|$|");
  nbDomElParam = matrixDomElemParameters.length-1;
   actionParam = element.parentNode.id;
  
   var divDomParam = document.createElement("DIV");  
  divDomParam.setAttribute("id", 'toremove');
  divDomParam.setAttribute("style", 'display:inline;');
  for (i=0;i<nbDomElParam;i++) {
      //divDomParam.innerHTML += "<span name='name_dom_el_to_valorise' class='textStyle'>" + matrixDomElemParameters[i] + "</span><select class='inputbox' style='margin-top:10px;' name='" + actionParam + "dom_el_to_valorise' id='" + matrixDomElemParameters[i] + "'>" + proc_param_html_options_bloc + "</select>";
      divDomParam.innerHTML += "<span name='name_dom_el_to_valorise' class='textStyle'>" + matrixDomElemParameters[i] + "</span><input class='inputbox' style='margin-top:10px;' name='" + actionParam + "dom_el_to_valorise' id='" + matrixDomElemParameters[i] + "' list='list" + matrixDomElemParameters[i] + "' onclick='this.value=\"\";'><datalist id='list" + matrixDomElemParameters[i] + "'>" + proc_param_html_options_bloc + "</datalist>";
    }
  divDomParam.innerHTML += "</div>";
  divDomEl.appendChild(divDomParam);
}

function majArrayProcedureParam() {
  var arrayprocparamname = [];
  var arrayprocparamdesc = [];
  input_proc_param_name = document.getElementsByName("input_proc_param_name");
  input_proc_param_desc = document.getElementsByName("input_proc_param_desc");
  proc_param_html_options_bloc = "";
  for (i=0;i<input_proc_param_name.length;i++) {
    arrayprocparamname.push(input_proc_param_name[i].value);
    proc_param_html_options_bloc += "<option value='" + input_proc_param_name[i].value + "'>param : " + input_proc_param_name[i].value + "</option>";
  }
  proc_param_html_options_bloc+= "<option selected value='\"" + titre_taper_la_valeur + "\"'>\"" + titre_taper_la_valeur + "\"</option>";
  for (i=0;i<input_proc_param_desc.length;i++) {
    arrayprocparamdesc.push(input_proc_param_desc[i].value);
  }
  
  add_action_param_name_select_element = document.getElementsByName("proc_param_html_options_bloc");
  for (i=0;i<add_action_param_name_select_element.length;i++) {
    add_action_param_name_select_element.innerHTML = proc_param_html_options_bloc;
  }
  
}

function addProcedureParamOut(n, d) {
  tableprocparameterout = document.getElementById("tableprocparameterout");
  var row = tableprocparameterout.insertRow(nbprocparamout);
  var procparamout = row.insertCell(0);
  nbprocparamout +=1;
  procparamout.innerHTML = "&nbsp;&nbsp;<input value=\"" + n + "\" size=20 maxlength='30' class='inputbox' placeholder='" + titre_param_name + "' name='input_proc_param_out_name' onchange='majStringReturn();'  pattern='[A-Za-z0-9]{1,30}' onKeyUp='formatasparam(this)' title='" + titre_format_param + "'/><input value=\"" + d + "\" size=50 maxlength='50' class='inputbox' placeholder='" + titre_description + "' name='input_proc_param_out_desc' />\n\<img id='delparambtn' src='/assets/icones/btnfail1.png' class='btnfail' onclick='this.parentNode.parentNode.removeChild(this.parentNode);majStringReturn();'></img>";
}

function majStringReturn() {
  textcode = editor1.getValue();
  lines = textcode.split("\n");
  textcode = "";
  for (i=0;i<lines.length;i++) {
    if (lines[i].indexOf("return ")!=0) {textcode += lines[i] + "\n";}  
  }
  listpname = document.getElementsByName("input_proc_param_out_name");
  return_string = "return "; 
  if (listpname) {
  for (i=0;i<listpname.length;i++) {
    if (i>0) {return_string += ", ";}
    return_string += listpname[i].value;
  }
  }
  editor1.setValue(textcode);
  if (return_string != "return ") {
  editor1.setValue(editor1.getValue() + return_string);
  }
}

function addProcedureParam(n, d, iscalled) {
  tableprocparameter = document.getElementById("tableprocparameter");
  var row = tableprocparameter.insertRow(nbprocparam);
  var procparam = row.insertCell(0);
  nbprocparam +=1;
  paramhtml = "&nbsp;&nbsp;<input value=\"" + n + "\" size=20 maxlength='30' class='inputbox' placeholder='" + titre_param_name + "' name='input_proc_param_name' onchange='changeParamValue(this, \"" + d + "\");'  pattern='[A-Za-z0-9]{1,30}' onKeyUp='formatasparam(this)' title='" + titre_format_param + "'";
  //if (iscalled == true) {paramhtml +=  " disabled ";}
  paramhtml += "/><input value=\"" + d + "\" size=50 maxlength='50' class='inputbox' placeholder='" + titre_description + "' name='input_proc_param_desc' />\n\<img id='delparambtn' src='/assets/icones/btnfail1.png' class='btnfail' onclick='this.parentNode.parentNode.removeChild(this.parentNode);majArrayProcedureParam();displayActionToAddParam();'></img>";
  procparam.innerHTML = paramhtml;
 }

function changeParamValue(elem, oldvalue) {
if (elem.checkValidity()) {
  majArrayProcedureParam();
  displayActionToAddParam();
} else {
  alert("format du nom incorrect");
  elem.value = oldvalue;	
  elem.focus();
}
}

function displayActionToAddParam()
{
if (document.getElementById("select_action_to_add")) {
actionid = document.getElementById("select_action_to_add").value;
if (actionid != "") {
actionarrayindex = arrayactionid.indexOf(actionid);
actionname = arrayactionname[actionarrayindex];
actionparam = arrayactionparam[actionarrayindex];
matrixparameters = actionparam.split("|$|");
td_selected_action_paramater = "<div style='width:100%;display:inline;'>";
nbparam = matrixparameters.length-1;

if (nbparam%2 > 0) {
  nbparam = (nbparam+1)/2;
} else {
  nbparam = nbparam/2;
}

for (i=0;i<nbparam;i++) {
  if (2*i+1 > matrixparameters.length-1) {
    paramname = "&nbsp;&nbsp;<span class='textStyle'>parameter : </span>";
    pname = 'inconnu';
  } else {
    paramname = "&nbsp;&nbsp;<span class='textStyle'>" + matrixparameters[2*i+1] + " : </span>";
    pname = matrixparameters[2*i+1];
  }
  if (matrixparameters[2*i] == "element") {
    paramtype = htmdomelement;
  } else {
    //paramtype = "<select class='inputbox' id='proc_param_html_options_bloc' name='proc_param_html_options_bloc' style='margin-top:10px;'>" + proc_param_html_options_bloc + "</select>";
    paramtype = "<input id='proc_param_html_options_bloc' name='proc_param_html_options_bloc' list='listproc_param_html_options_bloc' class='inputbox'  style='margin-top:10px;' onclick='this.value=\"\";'><datalist id='listproc_param_html_options_bloc' name='listproc_param_html_options_bloc'>" + proc_param_html_options_bloc + "</datalist>";
  }
  
  td_selected_action_paramater += "<div style='display:block;'><div id='" + pname  + "' style='display:inline-block;'><span class='textStyle' style='margin-top:0px;'>" + paramname + "</span>";
  td_selected_action_paramater += paramtype + "</div></div>";
  
}
document.getElementById("tdaddactionparams").innerHTML =  td_selected_action_paramater;
document.getElementById("btnaddaction").style.display = "inline-block";
} else {
document.getElementById("tdaddactionparams").innerHTML = "";
document.getElementById("btnaddaction").style.display = "none";

}	
}
}

function addProcedureActionToCode() {

  codeadded = "";
  selparams = document.getElementsByName("proc_param_html_options_bloc");
  procparams = document.getElementsByName("input_proc_param_name");
  if (action_return == "") {
		actioncallparam = "\n$action." + actionname + "(";
  } else {
	  actioncallparam = "\n" + action_return + " = $action." + actionname + "(";
  }
  for (i=0;i<selparams.length;i++) {
    if (i>0) {
      actioncallparam += ",";
    }
      
      parametredelaprocedure = selparams[i].parentNode.id;
      choixparametredelaprocedure = selparams[i].value;
	  if (selparams[i].id != "domelementliste") {
	  isparam = false;
	  for (p=0;p<procparams.length;p++) {
		  if (choixparametredelaprocedure == procparams[p].value) {
			  isparam = true;
			  break;
		  }
	  }
	  if (isparam == false) {choixparametredelaprocedure = "\"" + choixparametredelaprocedure + "\""};
	  }
      domparams = document.getElementsByName(parametredelaprocedure + "dom_el_to_valorise");
      affectationparametre = "\n" + parametredelaprocedure + " = " + choixparametredelaprocedure 
      if ((domparams!=null) && (domparams.length>0)) {
        affectationparametre += "\n" + parametredelaprocedure + ".setParameter(";
        for (j=0;j<domparams.length;j++) {
          if (j>0) {
            affectationparametre += ",";
          }
          parametredudomelement = domparams[j].id;
          valeurduparametredudomelement = domparams[j].value;
		  
		  isparam = false;
		  for (p=0;p<procparams.length;p++) {
			  if (valeurduparametredudomelement == procparams[p].value) {
				  isparam = true;
				  break;
			  }
		  }
		  if (isparam == false) {valeurduparametredudomelement = "\"" + valeurduparametredudomelement + "\""};
		  
          affectationparametre += "\"{" + parametredudomelement + "}\"," + valeurduparametredudomelement ;
        }
        affectationparametre += ")";
      }
      
      codeadded += affectationparametre;
      actioncallparam += parametredelaprocedure;
  }
  actioncallparam += ")";
  codeadded += actioncallparam + "\n";

  addTextToCode(codeadded);

  //return false
}
function addLogToCode() {
  texte = "$report.log('your log')";
  addTextToCode(texte);
}

function addPassToCode() {
  texte = "$report.pass('facultative:expected', 'facultative:detail pass')";
  addTextToCode(texte);
}

function addFailToCode() {
  texte = "$report.fail('facultative:expected', 'facultative:detail fail')";
  addTextToCode(texte);
}

function addCommentToCode() {
  texte = "# ";
  addTextToCode(texte);
}

function addIfToCode() {
  texte = "\nif #example: (a==b or b!=c and c>d) or d==nil\n\nelse\n\nend\n";
  addTextToCode(texte);
}

function addWhileToCode() {
  texte = "\nbegin\n\nend while #example: (a==b or b!=c and c>d) or d==nil\n";
  addTextToCode(texte);
}

function addUntilToCode() {
  texte = "\nbegin\n\nend until #example: (a==b or b!=c and c>d) or d==nil\n";
  addTextToCode(texte);
}

function addForToCode() {
  texte = "\nfor #example: i in 0..20\n\nend\n";
  addTextToCode(texte);
}

function addForEachToCode() {
  texte = "\nelements.each do |element| \n\nend\n";
  addTextToCode(texte);
}

function addPrisePhoto(nom) {
  texte = "\n$report.screenshot('" + nom + "')\n";
  addTextToCode(texte);
}
 
function addTextToCode(texte) {
  editor1.insert(texte);
  editor1.focus();
  }

function buildQueryString() {
  document.getElementById("procedure_code").value = editor1.getValue();
    
  listpname = document.getElementsByName("input_proc_param_name");
  listpdesc = document.getElementsByName("input_proc_param_desc");
  procedure_parameters = ""; 
  for (i=0;i<listpname.length;i++) {
    procedure_parameters += listpname[i].value + "|$|";
    procedure_parameters += listpdesc[i].value + "|$|";
  }
  document.getElementById("procedure_parameters").value = procedure_parameters;

  listpname = document.getElementsByName("input_proc_param_out_name");
  listpdesc = document.getElementsByName("input_proc_param_out_desc");
  procedure_parameters = ""; 
  for (i=0;i<listpname.length;i++) {
    procedure_parameters += listpname[i].value + "|$|";
    procedure_parameters += listpdesc[i].value + "|$|";
  }
  document.getElementById("procedure_parameters_out").value = procedure_parameters;

}










function checkuncheckall()
 {
    var checkboxes = document.getElementsByName("chbxinput");
     var val = document.getElementById("checkall").checked;
     for (var i = 0; i < checkboxes.length; i++) {
        if (!checkboxes[i].disabled) { 
            checkboxes[i].checked = val;
        }
    }
 }



 var lastProcClicked;
 function checkShift(event, chk)
 {
  if (event.shiftKey){
        var val = document.getElementById(lastProcClicked).checked;
        shiftClicked = chk;

        var checkboxes = document.getElementsByName("chbxinput");
        var startClick=false;
        var endClick=false;

        for (var i = 0; i < checkboxes.length; i++) {
                if (startClick==true && (checkboxes[i].id==lastProcClicked || checkboxes[i].id==shiftClicked)) {
                    endClick = true;
                    startClick = false;
                }
                if (startClick==false && endClick==false && (checkboxes[i].id==lastProcClicked || checkboxes[i].id==shiftClicked)) {
                    startClick = true;
                }
                if (startClick) {
                    checkboxes[i].checked = val;
                }
        }

    } else {
		lastProcClicked=chk;	
	}
 }
 
 
  function buildprocedureidstring() 
 {
    var checkboxes = document.getElementsByName("chbxinput");
    procstring = "";
    for (var i = 0; i < checkboxes.length; i++) {
        if (checkboxes[i].checked) {
            procstring = procstring + "|" + checkboxes[i].id + "|";
        }
    }    
    document.getElementById("proclist").value = procstring;
 }
 
 
 
   function addtotest(procedure_id, procedure_name, func_name, node_id) {
    window.parent.document.getElementById('idprocadded').value = procedure_id;
    window.parent.document.getElementById('nameprocadded').value = procedure_name;
    window.parent.document.getElementById('namefuncprocadded').value = func_name;
    window.parent.document.getElementById('idnodeprocadded').value = node_id;
    params = document.getElementsByName('param-' + procedure_id);
    paramstring = "";
    alertparam = "";
    for (i=0;i<params.length;i++) {
      if (i > 0) {
        alertparam += " , ";
      }
      paramstring += params[i].value + "|$|";
      alertparam += "\"" + params[i].value + "\"";
      params[i].value = "";
    }
    window.parent.document.getElementById('idparamstring').value = paramstring;
    window.parent.addproc();
    message = "Procédure " + procedure_name + "(" + alertparam + "), en cours d'enregistrement" ;
    document.getElementById('message').innerHTML = "<span class='infoMessage' onclick='this.parentNode.removeChild(this)'  style='vertical-align: top;'>" + message + "<b>&nbsp;&nbsp;&nbsp;&nbsp;x</b></span>";
  }
  
  function displayparambox(el, i, name) {
    if (el.value=='valeur') {
      document.getElementById("paramenv-" + i).style.display = 'none';
      document.getElementById("paramconf-" + i).style.display = 'none';
      document.getElementById("paramconst-" + i).style.display = 'none';
	  document.getElementById("paramjdd-" + i).style.display = 'none';
      document.getElementById("paramval-" + i).style.display = 'inline';
      document.getElementById("paramenv-" + i).setAttribute('name', 'x');
      document.getElementById("paramconf-" + i).setAttribute('name', 'x');
      document.getElementById("paramconst-" + i).setAttribute('name', 'x');
      document.getElementById("paramval-" + i).setAttribute('name', name);
	  document.getElementById("paramjdd-" + i).setAttribute('name', 'x');
	  document.getElementById("paramatdd-" + i).style.display = 'none';
	  document.getElementById("paramatdd-" + i).setAttribute('name', 'x');
    }
    if (el.value=='env') {
      document.getElementById("paramenv-" + i).style.display = 'inline';
      document.getElementById("paramconf-" + i).style.display = 'none';
      document.getElementById("paramconst-" + i).style.display = 'none';
      document.getElementById("paramval-" + i).style.display = 'none';
	  document.getElementById("paramjdd-" + i).style.display = 'none';
      document.getElementById("paramenv-" + i).setAttribute('name', name);
      document.getElementById("paramconf-" + i).setAttribute('name', 'x');
      document.getElementById("paramconst-" + i).setAttribute('name', 'x');
      document.getElementById("paramval-" + i).setAttribute('name', 'x');
	  document.getElementById("paramjdd-" + i).setAttribute('name', 'x');
	  document.getElementById("paramatdd-" + i).style.display = 'none';
	  document.getElementById("paramatdd-" + i).setAttribute('name', 'x');
    }
    if (el.value=='conf') {
      document.getElementById("paramenv-" + i).style.display = 'none';
      document.getElementById("paramconf-" + i).style.display = 'inline';
      document.getElementById("paramconst-" + i).style.display = 'none';
      document.getElementById("paramval-" + i).style.display = 'none';
	  document.getElementById("paramjdd-" + i).style.display = 'none';
      document.getElementById("paramenv-" + i).setAttribute('name', 'x');
      document.getElementById("paramconf-" + i).setAttribute('name', name);
      document.getElementById("paramconst-" + i).setAttribute('name', 'x');
      document.getElementById("paramval-" + i).setAttribute('name', 'x');
	  document.getElementById("paramjdd-" + i).setAttribute('name', 'x');
	  document.getElementById("paramatdd-" + i).style.display = 'none';
	  document.getElementById("paramatdd-" + i).setAttribute('name', 'x');
    }
    if (el.value=='const') {
      document.getElementById("paramenv-" + i).style.display = 'none';
      document.getElementById("paramconf-" + i).style.display = 'none';
      document.getElementById("paramconst-" + i).style.display = 'inline';
      document.getElementById("paramval-" + i).style.display = 'none';
	  document.getElementById("paramjdd-" + i).style.display = 'none';
      document.getElementById("paramenv-" + i).setAttribute('name', 'x');
      document.getElementById("paramconf-" + i).setAttribute('name', 'x');
      document.getElementById("paramconst-" + i).setAttribute('name', name);
      document.getElementById("paramval-" + i).setAttribute('name', 'x');
	  document.getElementById("paramjdd-" + i).setAttribute('name', 'x');
	  document.getElementById("paramatdd-" + i).style.display = 'none';
	  document.getElementById("paramatdd-" + i).setAttribute('name', 'x');
    }
	if (el.value=='jdd') {
      document.getElementById("paramenv-" + i).style.display = 'none';
      document.getElementById("paramconf-" + i).style.display = 'none';
      document.getElementById("paramconst-" + i).style.display = 'none';
      document.getElementById("paramval-" + i).style.display = 'none';
	  document.getElementById("paramjdd-" + i).style.display = 'inline';
      document.getElementById("paramenv-" + i).setAttribute('name', 'x');
      document.getElementById("paramconf-" + i).setAttribute('name', 'x');
      document.getElementById("paramconst-" + i).setAttribute('name', 'x');
      document.getElementById("paramval-" + i).setAttribute('name', 'x');
	  document.getElementById("paramjdd-" + i).setAttribute('name', name);
	  document.getElementById("paramatdd-" + i).style.display = 'none';
	  document.getElementById("paramatdd-" + i).setAttribute('name', 'x');
    }
	if (el.value=='atdd') {
      document.getElementById("paramenv-" + i).style.display = 'none';
      document.getElementById("paramconf-" + i).style.display = 'none';
      document.getElementById("paramconst-" + i).style.display = 'none';
      document.getElementById("paramval-" + i).style.display = 'none';
	  document.getElementById("paramjdd-" + i).style.display = 'none';
      document.getElementById("paramenv-" + i).setAttribute('name', 'x');
      document.getElementById("paramconf-" + i).setAttribute('name', 'x');
      document.getElementById("paramconst-" + i).setAttribute('name', 'x');
      document.getElementById("paramval-" + i).setAttribute('name', 'x');
	  document.getElementById("paramjdd-" + i).setAttribute('name', 'x');
	  document.getElementById("paramatdd-" + i).style.display = 'inline';
	  document.getElementById("paramatdd-" + i).setAttribute('name', name);
    }
  }
  