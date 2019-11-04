var HF = 100;
var LF = 160;

function zoomsvg(coeff) {
	document.getElementById('scale').value=document.getElementById('scale').value*coeff;
	var scale=document.getElementById('scale').value;
	document.getElementById('mainG').setAttribute('transform', 'scale(' + scale + ' , ' + scale + ')');
}

function formate_string_svg_t_span(str) {
    return str.replace(/&#39;/g, "'").replace(/&quot;/g, "\"").replace(/&amp;/g, "&").replace(/&gt;/g, ">").replace(/&lt;/g, "<");
}

function newAppElemDesign(idel, matrix, name, objtype, linkedobj, locked, show, screen) {
	mainG = document.getElementById("mainG");
	if (mainG == null) {
		var mainG = document.createElementNS('http://www.w3.org/2000/svg', "g");
		mainG.setAttribute('id', 'mainG');
	}
    if (screen == "testedit") {
        HF = 60;
        LF = 150;
    } else {
        HF = 60;
        LF = 150;
    }
    number = idel;
    if (objtype == "conceptionsheet") {
        splitlinkedobj = linkedobj.split("||*$*||");
        linkedobj = splitlinkedobj[0];
        if (splitlinkedobj.length > 1) {
            name = splitlinkedobj[1];
        }
    }
    if (objtype == "funcscreen") {
        splitlinkedobj = linkedobj.split("||*$*||");
        linkedobj = "";
        if (splitlinkedobj.length == 1) {
            linkedobj = splitlinkedobj[0];
        }
    }
    if (objtype == "existingfuncscreen") {
        objtype = "funcscreen";
        splitlinkedobj = linkedobj.split("||*$*||");
        linkedobj = splitlinkedobj[0];
        if (splitlinkedobj.length > 1) {
            name = splitlinkedobj[1];
        }
    }
    if (name == '') {
        name = titre_node_defaut;
    }
    var s = document.getElementById('svg');
    var g_fiche = document.createElementNS('http://www.w3.org/2000/svg', "g");
    var g_deleteButton = document.createElementNS('http://www.w3.org/2000/svg', "g");
    var g_objrepButton = document.createElementNS('http://www.w3.org/2000/svg', "g");
    var g_proclistButton = document.createElementNS('http://www.w3.org/2000/svg', "g");
    var g_addsonButton = document.createElementNS('http://www.w3.org/2000/svg', "g");

    var r_maincadre = document.createElementNS('http://www.w3.org/2000/svg', "rect");
    var r_cadredeletebutton = document.createElementNS('http://www.w3.org/2000/svg', "rect");
    var r_dossierobjbottom = document.createElementNS('http://www.w3.org/2000/svg', "rect");
    var r_dossierobjtop = document.createElementNS('http://www.w3.org/2000/svg', "rect");
    var r_dossierproctop = document.createElementNS('http://www.w3.org/2000/svg', "rect");
    var r_dossierprocmid = document.createElementNS('http://www.w3.org/2000/svg', "rect");
    var r_dossierprocbottom = document.createElementNS('http://www.w3.org/2000/svg', "rect");

    var p_btnlinkto = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btndeleteline = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btndeletecrossline = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btnaddsonline = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btnaddsoncrossline = document.createElementNS('http://www.w3.org/2000/svg', "path");

    var c_btnlinkfrom = document.createElementNS('http://www.w3.org/2000/svg', "circle");
    var c_btnaddson = document.createElementNS('http://www.w3.org/2000/svg', "circle");

    var t_ficnumber = document.createElementNS('http://www.w3.org/2000/svg', "text");
    var t_fictitle = document.createElementNS('http://www.w3.org/2000/svg', "text");

    var title_g_deleteButton = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_g_objrepButton = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_g_proclistButton = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_c_btnlinkfrom = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_p_btnlinkto = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_g_btnaddson = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_t_ficnumber = document.createElementNS('http://www.w3.org/2000/svg', "title");

    title_g_deleteButton.textContent = titre_del_button;
    title_g_objrepButton.textContent = titre_objrep_button;
    title_g_proclistButton.textContent = titre_procedures;
    title_c_btnlinkfrom.textContent = titre_lien_a_partir;
    title_p_btnlinkto.textContent = titre_lien_vers;
    title_g_btnaddson.textContent = titre_ajout_fils;
    title_t_ficnumber.textContent = titre_detail;

    g_fiche.setAttribute('transform', matrix);
    g_fiche.setAttribute('class', 'draggable');
    g_fiche.setAttribute('id', 'elG' + idel);
    g_fiche.setAttribute('name', 'elG');
    g_fiche.setAttribute('nodetype', 'card');
    g_fiche.setAttribute('objtype', objtype);
    g_fiche.setAttribute('linkedobj', linkedobj);


    g_deleteButton.setAttribute('transform', 'translate(' + LF * 0.92 + ', 0)');
    g_deleteButton.setAttribute('class', 'clickable');
    g_deleteButton.setAttribute('id', 'deletebtn' + idel);

    g_objrepButton.setAttribute('transform', 'translate(' + LF * 0.15 + ', ' + HF * 0.68 + ') scale(0.15, 0.15)');
    g_objrepButton.setAttribute('class', 'clickable');
    g_objrepButton.setAttribute('id', 'objrepbtn' + idel);

    g_proclistButton.setAttribute('transform', 'translate(' + LF * 0.68 + ', ' + HF * 0.63 + ') scale(0.15, 0.15)');
    g_proclistButton.setAttribute('class', 'clickable');
    g_proclistButton.setAttribute('id', 'proclistbtn' + idel);

    g_addsonButton.setAttribute('transform', 'translate(' + LF * 0.5 + ', ' + HF * 0.68 + ') scale(0.25, 0.25)');
    g_addsonButton.setAttribute('class', 'clickable');
    g_addsonButton.setAttribute('id', 'addbtn' + idel);

    r_maincadre.setAttribute('id', 'maincadre' + idel);
    r_maincadre.setAttribute('x', '0');
    r_maincadre.setAttribute('y', '0');
    r_maincadre.setAttribute('rx', '3');
    r_maincadre.setAttribute('ry', '3');
    r_maincadre.setAttribute('width', LF);
    r_maincadre.setAttribute('height', HF);
    if (objtype == "conceptionsheet") {
        r_maincadre.setAttribute('style', 'fill:url(#OrangeDegrade);fill-opacity:0.25;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
    }
    if (objtype == "funcscreen") {
        r_maincadre.setAttribute('style', 'fill:url(#vertDegrade);fill-opacity:0.25;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
    }

    r_cadredeletebutton.setAttribute('transform', 'scale(0.08, 0.08)');
    r_cadredeletebutton.setAttribute('id', 'cadredeletebtn' + idel);
    r_cadredeletebutton.setAttribute('x', '0');
    r_cadredeletebutton.setAttribute('y', '0');
    r_cadredeletebutton.setAttribute('width', LF);
    r_cadredeletebutton.setAttribute('height', LF);
    r_cadredeletebutton.setAttribute('style', 'fill:#b3b3b3;fill-opacity:0.5008354;stroke:#000000;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');

    r_dossierobjbottom.setAttribute('id', 'cadreobj1_' + idel);
    r_dossierobjbottom.setAttribute('x', '0');
    r_dossierobjbottom.setAttribute('y', HF / 10);
    r_dossierobjbottom.setAttribute('rx', LF / 10);
    r_dossierobjbottom.setAttribute('ry', HF / 10);
    r_dossierobjbottom.setAttribute('width', LF);
    r_dossierobjbottom.setAttribute('height', LF / 2);
    r_dossierobjbottom.setAttribute('style', 'opacity:1;fill:#ff0000;fill-opacity:0.5008354;stroke:#000000;stroke-width:' + LF / 40 + ';stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:markers fill stroke');

    r_dossierobjtop.setAttribute('id', 'cadreobj2_' + idel);
    r_dossierobjtop.setAttribute('x', LF / 30);
    r_dossierobjtop.setAttribute('y', '0');
    r_dossierobjtop.setAttribute('rx', LF / 20);
    r_dossierobjtop.setAttribute('ry', HF / 20);
    r_dossierobjtop.setAttribute('width', LF / 3);
    r_dossierobjtop.setAttribute('height', LF / 10);
    r_dossierobjtop.setAttribute('style', 'opacity:1;fill:#ff0000;fill-opacity:0.5008354;stroke:#000000;stroke-width:' + LF / 40 + ';stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:markers fill stroke');

    r_dossierproctop.setAttribute('id', 'cadreproc1_' + idel);
    r_dossierproctop.setAttribute('x', '0');
    r_dossierproctop.setAttribute('y', '0');
    r_dossierproctop.setAttribute('width', LF);
    r_dossierproctop.setAttribute('height', LF / 2);
    r_dossierproctop.setAttribute('style', 'opacity:1;fill:#aa4400;fill-opacity:0.5008354;stroke:#000000;stroke-width:' + LF / 40 + ';stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:markers fill stroke');

    r_dossierprocmid.setAttribute('id', 'cadreproc2_' + idel);
    r_dossierprocmid.setAttribute('x', '0');
    r_dossierprocmid.setAttribute('y', '0');
    r_dossierprocmid.setAttribute('width', LF);
    r_dossierprocmid.setAttribute('height', LF / 2);
    r_dossierprocmid.setAttribute('transform', 'translate(' + LF / 10 + ',' + LF / 10 + ')');
    r_dossierprocmid.setAttribute('style', 'opacity:1;fill:#aa4400;fill-opacity:0.5008354;stroke:#000000;stroke-width:' + LF / 40 + ';stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:markers fill stroke');

    r_dossierprocbottom.setAttribute('id', 'cadreproc3_' + idel);
    r_dossierprocbottom.setAttribute('x', '0');
    r_dossierprocbottom.setAttribute('y', '0');
    r_dossierprocbottom.setAttribute('width', LF);
    r_dossierprocbottom.setAttribute('height', LF / 2);
    r_dossierprocbottom.setAttribute('transform', 'translate(' + 2 * LF / 10 + ',' + 2 * LF / 10 + ')');
    r_dossierprocbottom.setAttribute('style', 'opacity:1;fill:#aa4400;fill-opacity:0.5008354;stroke:#000000;stroke-width:' + LF / 40 + ';stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;paint-order:markers fill stroke');

    p_btnlinkto.setAttribute('transform', 'translate(' + LF * 0.6 + ', 1) scale(0.08, 0.08)');
    p_btnlinkto.setAttribute('d', "m 0,0 " + LF + "," + LF / 2 + " -" + LF + " ," + LF / 2 + " z");
    p_btnlinkto.setAttribute('id', 'linkto' + idel);
    p_btnlinkto.setAttribute('class', 'clickable');
    p_btnlinkto.setAttribute('style', "fill:#000000;fill-opacity:0.5008354;stroke:#000000;stroke-width:" + LF / 40 + ";stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1");

    p_btndeleteline.setAttribute('d', "M 0," + LF * 0.08 + " " + LF * 0.08 + ",0");
    p_btndeleteline.setAttribute('style', "fill:none;stroke:#000000;stroke-width:2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    p_btndeletecrossline.setAttribute('d', "m 0,0 " + LF * 0.08 + "," + LF * 0.08 + "");
    p_btndeletecrossline.setAttribute('style', "fill:none;stroke:#000000;stroke-width:2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    p_btnaddsonline.setAttribute('d', "M 0," + HF * 0.2 + " 0, " + HF * 0.8);
    p_btnaddsonline.setAttribute('style', "fill:none;stroke:#1C6800;stroke-width:" + LF / 10 + ";stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    p_btnaddsoncrossline.setAttribute('d', "m -" + HF * 0.3 + "," + HF / 2 + " " + HF * 0.6 + ",0");
    p_btnaddsoncrossline.setAttribute('style', "fill:none;stroke:#1C6800;stroke-width:" + LF / 10 + ";stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    c_btnlinkfrom.setAttribute('transform', 'translate(' + LF * 0.78 + ', 1) scale(0.08, 0.08)');
    c_btnlinkfrom.setAttribute('class', 'clickable');
    c_btnlinkfrom.setAttribute('id', 'linkfrom' + idel);
    c_btnlinkfrom.setAttribute('cx', 0);
    c_btnlinkfrom.setAttribute('cy', LF / 2);
    c_btnlinkfrom.setAttribute('r', LF / 2);
    c_btnlinkfrom.setAttribute('fill', "green");
    c_btnlinkfrom.setAttribute('style', "fill-opacity:0.5008354;stroke:#000000;stroke-width:" + LF / 40 + ";stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    c_btnaddson.setAttribute('cx', 0);
    c_btnaddson.setAttribute('cy', HF / 2);
    c_btnaddson.setAttribute('r', HF / 2);
    c_btnaddson.setAttribute('fill', "#3DC30C");
    c_btnaddson.setAttribute('style', "fill-opacity:1;stroke:#1C6800;stroke-width:" + LF / 10 + ";stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");


    t_ficnumber.setAttribute('x', '4');
    t_ficnumber.setAttribute('y', '15');
    t_ficnumber.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:#000000;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    if (objtype == "conceptionsheet") {
		t_ficnumber.textContent = '#' + number + "...";
		t_ficnumber.setAttribute('class', 'clickable');
		t_ficnumber.appendChild(title_t_ficnumber);
	} else {
		t_ficnumber.textContent = '#' + number;
	}
    

    t_fictitle.setAttribute('id', 'texttitle' + idel);
    t_fictitle.setAttribute('x', '6');
    t_fictitle.setAttribute('y', '20');
    t_fictitle.setAttribute('width', LF * 0.8);
    t_fictitle.setAttribute('height', HF / 3);

    if (name == titre_node_defaut) {
        t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:red;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    } else {
        t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    }


    s_titre = name;
    s_splite_titre = s_titre.split("\n");
    for (var nbl = 0; nbl < s_splite_titre.length; nbl++) {
        var t_span = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
        t_span.setAttribute("name", "tspantexttitle" + idel);
        t_span.textContent = formate_string_svg_t_span(s_splite_titre[nbl]);
        t_fictitle.appendChild(t_span);
        t_span.setAttribute('x', '6');
        t_span.setAttribute('dy', '12');
    }
    ;

    t_fictitle.setAttribute('class', 'clickable');

    g_deleteButton.appendChild(r_cadredeletebutton);
    g_deleteButton.appendChild(p_btndeleteline);
    g_deleteButton.appendChild(p_btndeletecrossline);
    g_deleteButton.appendChild(title_g_deleteButton);

    g_objrepButton.appendChild(r_dossierobjbottom);
    g_objrepButton.appendChild(r_dossierobjtop);
    g_objrepButton.appendChild(title_g_objrepButton);

    g_proclistButton.appendChild(r_dossierproctop);
    g_proclistButton.appendChild(r_dossierprocmid);
    g_proclistButton.appendChild(r_dossierprocbottom);
    g_proclistButton.appendChild(title_g_proclistButton);

    g_addsonButton.appendChild(c_btnaddson);
    g_addsonButton.appendChild(p_btnaddsonline);
    g_addsonButton.appendChild(p_btnaddsoncrossline);
    g_addsonButton.appendChild(title_g_btnaddson);

    p_btnlinkto.appendChild(title_p_btnlinkto);
    c_btnlinkfrom.appendChild(title_c_btnlinkfrom);

    g_fiche.appendChild(r_maincadre);
    g_fiche.appendChild(t_ficnumber);

    if (objtype == "funcscreen" && screen == "sheetedit") {
        g_fiche.appendChild(g_objrepButton);
        g_fiche.appendChild(g_proclistButton);
        g_objrepButton.setAttribute('onclick', "document.getElementById('contentpopup').innerHTML=\"<object id='objpopup' width='99%' data='../domelements/index?popup=true&sheet_id=" + document.getElementById('sheetinit').value + "&ext_node_id=" + idel + "'></object>\";window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);");
        g_proclistButton.setAttribute('onclick', "document.getElementById('contentpopup').innerHTML=\"<object id='objpopup' width='99%' data='../procedures/index?popup=true&sheet_id=" + document.getElementById('sheetinit').value + "&ext_node_id=" + idel + "'></object>\";window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);");
    }

    if (objtype == "funcscreen" && screen == "testedit") {
        g_fiche.appendChild(g_objrepButton);
        g_fiche.appendChild(g_proclistButton);
        g_objrepButton.setAttribute('onclick', "document.getElementById('contentpopup').innerHTML=\"<object id='objpopup' width='99%' data='../domelements/index?popup=true&sheet_id=" + document.getElementById('sheetinit').value + "&ext_node_id=" + idel + "'></object>\";window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);");
        g_proclistButton.setAttribute('onclick', "document.getElementById('contentpopup').innerHTML=\"<object id='objpopup' width='99%' data='../procedures/listtoaddtotest?popup=true&write=" + document.getElementById('write').value + "&lock=" + document.getElementById('lock').value + "&sheet_id=" + document.getElementById('sheetinit').value + "&ext_node_id=" + idel + "&atdd_param="+ document.getElementById('atdd_param').value +"'></object>\";window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);");
    }


    g_fiche.appendChild(t_fictitle);
    if (locked == false && screen == "sheetedit") {
        g_fiche.appendChild(p_btnlinkto);
        g_fiche.appendChild(c_btnlinkfrom);
        g_fiche.appendChild(g_deleteButton);
        g_fiche.appendChild(g_addsonButton);
        g_deleteButton.setAttribute('onclick', 'deleteElement("cadre", "' + 'elG' + idel + '")');
        g_addsonButton.setAttribute('onclick', 'addElement(' + idel + ', document.getElementById("objtypetoadd").value, document.getElementById("objToLink").value, false, true,"' + screen + '");');
        p_btnlinkto.setAttribute('onclick', 'setLinkTo("' + idel + '")');
        c_btnlinkfrom.setAttribute('onclick', 'setLinkFrom("' + idel + '")');
        t_fictitle.setAttribute('onclick', "switchTextToInput('elG" + idel + "', 'texttitle" + idel + "', '" + idel + "');");
    }
    g_fiche.setAttribute('onmousedown', "selectElement(evt, '" + idel + "')");
    t_ficnumber.setAttribute('onclick', 'showDetail("' + idel + '")');
    if (show) {
		mainG.appendChild(g_fiche);
        s.appendChild(mainG);
        bbox = t_fictitle.getBBox();
        newlf = Math.max(bbox.width + 20, LF);
        newhf = Math.max(bbox.height + 2 * HF / 3, HF);
        if ((newlf > LF) || (newhf > HF)) {
            r_maincadre.setAttribute("width", newlf);
            r_maincadre.setAttribute("height", newhf);
            g_deleteButton.setAttribute('transform', 'translate(' + (newlf - (LF * 0.08)) + ', 0)');
            p_btnlinkto.setAttribute('transform', 'translate(' + newlf * 0.6 + ', 1)  scale(0.08, 0.08)');
            c_btnlinkfrom.setAttribute('transform', 'translate(' + newlf * 0.78 + ', 1)  scale(0.08, 0.08)');
            g_objrepButton.setAttribute('transform', 'translate(' + (newlf * 0.5 - LF * 0.35) + ', ' + (newhf - HF * 0.26) + ')  scale(0.15, 0.15)');
            g_proclistButton.setAttribute('transform', 'translate(' + (newlf * 0.5 + LF * 0.18) + ', ' + (newhf - HF * 0.32) + ')  scale(0.15, 0.15)');
            g_addsonButton.setAttribute('transform', 'translate(' + newlf * 0.5 + ', ' + (newhf - HF * 0.26) + ')  scale(0.25, 0.25)');
        }
    }
	
}

function switchTextToInput(idFiche, idText, idel) {
    var f_textarea = document.createElementNS('http://www.w3.org/2000/svg', "foreignObject");
    objectmove = true;
    document.getElementById('elG' + idel).setAttribute('onmousedown', "");

    eltorem = document.getElementById(idText);
    //tspans=document.getElementsByName("tspantexttitle"+ idel);
    tspans = document.getElementsByTagName("tspan");
    var innertext = "";
	nrow = 1;
    for (nbl = 0; nbl < tspans.length; nbl++) {
        if (tspans[nbl].getAttribute("name") == "tspantexttitle" + idel) {
            innertext += tspans[nbl].textContent + "\n";
			nrow += 1;
        }
    }
    htmlforeign = "<textarea spellcheck='false' style=\"font-family: Verdana, Geneva, sans-serif;font-size:12px\" id=\"inputtitle" + idel + "\" name=\"inputtitle" + idel + "\" rows=" + nrow + " cols=50 maxlength='250' onblur=\"switchInputToText('" + idFiche + "', 'for" + idel + "', 'inputtitle" + idel + "', '" + idText + "', '" + idel + "');\">" + innertext + "</textarea>";
    f_textarea.setAttribute('id', 'for' + idel);
    f_textarea.setAttribute('x', '6');
    f_textarea.setAttribute('y', '20');
    f_textarea.setAttribute('width', LF);
    f_textarea.setAttribute('height', HF);
    f_textarea.innerHTML = htmlforeign;

    eltorem.remove();
    fiche = document.getElementById(idFiche);
    fiche.appendChild(f_textarea);
    document.getElementById("inputtitle" + idel).focus();
}

function switchInputToText(idFiche, idForeign, idTextarea, idText, idel) {
    var t_fictitle = document.createElementNS('http://www.w3.org/2000/svg', "text");
    objectmove = false;
    document.getElementById('elG' + idel).setAttribute('onmousedown', "selectElement(evt, '" + idel + "')");

    eltorem = document.getElementById(idForeign);
    eltxtarea = document.getElementById(idTextarea);
    t_fictitle.setAttribute('id', idText);
    t_fictitle.setAttribute('x', '6');
    t_fictitle.setAttribute('y', '20');
    t_fictitle.setAttribute('width', LF * 0.8);
    t_fictitle.setAttribute('height', HF / 3);


    if (eltxtarea.value.replace('\n', '') == titre_node_defaut) {
        t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:red;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    } else {
        t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    }

    //t_fictitle.textContent=eltxtarea.value;
    texttitle = "";
    s_splite_titre = eltxtarea.value.split("\n");
    for (var nbl = 0; nbl < s_splite_titre.length; nbl++) {
        if (s_splite_titre[nbl].trim() != "") {
            var t_span = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
            t_span.setAttribute("name", "tspantexttitle" + idel);
            t_span.textContent = formate_string_svg_t_span(s_splite_titre[nbl]);
            t_fictitle.appendChild(t_span);
            t_span.setAttribute('x', '6');
            t_span.setAttribute('dy', '12');
            texttitle += s_splite_titre[nbl].trim();
        }
    }
    ;
    if (texttitle.trim() == "") {
        var t_span = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
        t_span.setAttribute("name", "tspantexttitle" + idel);
        t_span.textContent = titre_node_defaut;
        t_fictitle.appendChild(t_span);
        t_span.setAttribute('x', '6');
        t_span.setAttribute('dy', '12');
    }
    t_fictitle.setAttribute('class', 'clickable');
    t_fictitle.setAttribute('onclick', "switchTextToInput('" + idFiche + "', '" + idText + "', '" + idel + "');");

    eltorem.remove();



    fiche = document.getElementById(idFiche);
    fiche.appendChild(t_fictitle);
    majHiddenRepresentation("elG" + idel, "merge", null, true);
    bbox = t_fictitle.getBBox();
    newlf = Math.max(bbox.width + 20, LF);
    newhf = Math.max(bbox.height + 2 * HF / 3, HF);
    if ((newlf != LF) || (newhf != HF)) {
        r_maincadre = document.getElementById("maincadre" + idel);
        g_deleteButton = document.getElementById('deletebtn' + idel);
        g_objrepButton = document.getElementById('objrepbtn' + idel);
        g_proclistButton = document.getElementById('proclistbtn' + idel);
        g_addsonButton = document.getElementById('addbtn' + idel);
        c_btnlinkfrom = document.getElementById('linkfrom' + idel);
        p_btnlinkto = document.getElementById('linkto' + idel);
        r_maincadre.setAttribute("width", newlf);
        r_maincadre.setAttribute("height", newhf);
        g_deleteButton.setAttribute('transform', 'translate(' + (newlf - (LF * 0.12)) + ', 0)');
        p_btnlinkto.setAttribute('transform', 'translate(' + newlf * 0.6 + ', 1)  scale(0.08, 0.08)');
        c_btnlinkfrom.setAttribute('transform', 'translate(' + newlf * 0.78 + ', 1)  scale(0.08, 0.08)');
        g_objrepButton.setAttribute('transform', 'translate(' + (newlf * 0.5 - LF * 0.4) + ', ' + (newhf - HF * 0.32) + ')  scale(0.2, 0.2)');
        g_proclistButton.setAttribute('transform', 'translate(' + (newlf * 0.5 + LF * 0.18) + ', ' + (newhf - HF * 0.32) + ')  scale(0.2, 0.2)');
        g_addsonButton.setAttribute('transform', 'translate(' + newlf * 0.5 + ', ' + (newhf - HF * 0.22) + ')  scale(0.2, 0.2)');
    }
}


function newSuiteTestElement(idel, matrix, name, objtype, linkedobj, locked, show, screen, forced_config, hold, newthread, testtype) {
	mainG = document.getElementById("mainG");
	if (mainG == null) {
		var mainG = document.createElementNS('http://www.w3.org/2000/svg', "g");
		mainG.setAttribute('id', 'mainG');
	}
    HF = 40;
    LF = 160;
    isnotstart = true;
    if (objtype == 'starttestsuite') {
        LF = 80;
        isnotstart = false;
    }
    number = idel;
    if (objtype == "testinsuite") {
        splitlinkedobj = linkedobj.split("||*$*||");
        linkedobj = splitlinkedobj[0];
        if (splitlinkedobj.length > 1) {
            name = splitlinkedobj[1];
        }
		if (splitlinkedobj.length > 2) {
            testtype = splitlinkedobj[2];
        }
    }


    var s = document.getElementById('svg');
    var g_fiche = document.createElementNS('http://www.w3.org/2000/svg', "g");
    var g_deleteButton = document.createElementNS('http://www.w3.org/2000/svg', "g");
    var g_addsonButton = document.createElementNS('http://www.w3.org/2000/svg', "g");

    var r_maincadre = document.createElementNS('http://www.w3.org/2000/svg', "rect");
    var r_cadredeletebutton = document.createElementNS('http://www.w3.org/2000/svg', "rect");

    var p_btnlinkto = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btndeleteline = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btndeletecrossline = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btnaddsonline = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btnaddsoncrossline = document.createElementNS('http://www.w3.org/2000/svg', "path");

    var c_btnlinkfrom = document.createElementNS('http://www.w3.org/2000/svg', "circle");
    var c_btnaddson = document.createElementNS('http://www.w3.org/2000/svg', "circle");

    var c_forceconfig = document.createElementNS('http://www.w3.org/2000/svg', "circle");
    var c_holdunhold = document.createElementNS('http://www.w3.org/2000/svg', "circle");

    var t_fictitle = document.createElementNS('http://www.w3.org/2000/svg', "text");
    var t_gotest = document.createElementNS('http://www.w3.org/2000/svg', "text");
    var t_newthread = document.createElementNS('http://www.w3.org/2000/svg', "text");
    var t_samethread = document.createElementNS('http://www.w3.org/2000/svg', "text");

    var title_g_deleteButton = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_c_btnlinkfrom = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_p_btnlinkto = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_g_btnaddson = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_c_forceconfig = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_t_gotest = document.createElementNS('http://www.w3.org/2000/svg', "title");
	var title_t_newthread = document.createElementNS('http://www.w3.org/2000/svg', "title");
	var title_t_samethread = document.createElementNS('http://www.w3.org/2000/svg', "title");
	var title_c_holdunhold = document.createElementNS('http://www.w3.org/2000/svg', "title");
	
    var t_span_gottest = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
	var t_span_newthread = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
	var t_span_samethread = document.createElementNS('http://www.w3.org/2000/svg', "tspan");

    t_span_gottest.textContent = ">> ";
	t_span_newthread.textContent = "NT";
	t_span_samethread.textContent = "ST";
    t_gotest.appendChild(t_span_gottest);
	t_newthread.appendChild(t_span_newthread);
	t_samethread.appendChild(t_span_samethread);
    t_span_gottest.setAttribute('x', '2');
    t_span_gottest.setAttribute('dy', '12');
    t_span_newthread.setAttribute('dx', '-24');
    t_span_newthread.setAttribute('dy', '-5');
    t_span_samethread.setAttribute('dx', '-24');
    t_span_samethread.setAttribute('dy', '-5');

    t_gotest.setAttribute('id', 'texttitle' + idel);
    t_gotest.setAttribute('x', '2');
    t_gotest.setAttribute('y', '10');
    t_gotest.setAttribute('width', LF * 0.8);
    t_gotest.setAttribute('height', HF / 3);
    t_gotest.setAttribute('style', "font-style:normal;font-weight:bold;font-size:12px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    t_gotest.setAttribute('class', 'clickable');

    t_newthread.setAttribute('id', 'newthread' + idel);
    t_newthread.setAttribute('x', LF);
    t_newthread.setAttribute('y', HF);
    t_newthread.setAttribute('width', '24');
    t_newthread.setAttribute('height', '12');
    t_newthread.setAttribute('style', "font-style:normal;font-weight:bold;font-size:12px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    t_newthread.setAttribute('class', 'clickable');

    t_samethread.setAttribute('id', 'samethread' + idel);
    t_samethread.setAttribute('x', LF);
    t_samethread.setAttribute('y', HF);
    t_samethread.setAttribute('width', '24');
    t_samethread.setAttribute('height', '12');
    t_samethread.setAttribute('style', "font-style:normal;font-weight:bold;font-size:12px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    t_samethread.setAttribute('class', 'clickable');
	
    title_g_deleteButton.textContent = titre_del_button;
    title_c_btnlinkfrom.textContent = titre_lien_a_partir;
    title_p_btnlinkto.textContent = titre_lien_vers;
    title_g_btnaddson.textContent = titre_ajout_fils;
    title_c_forceconfig.textContent = titre_force_config;
    title_t_gotest.textContent = titre_go_test;
	title_t_newthread.textContent = titre_nouveau_thread;
	title_t_samethread.textContent = titre_meme_thread;
	
	title_c_holdunhold.setAttribute('id', 'titlehold' + idel);
	
    g_fiche.setAttribute('transform', matrix);
    g_fiche.setAttribute('class', 'draggable');
    g_fiche.setAttribute('id', 'elG' + idel);
    g_fiche.setAttribute('name', 'elG');
    g_fiche.setAttribute('nodetype', 'card');
    g_fiche.setAttribute('objtype', objtype);
    g_fiche.setAttribute('linkedobj', linkedobj);
	g_fiche.setAttribute('newthread', newthread);
	g_fiche.setAttribute('testtype', testtype);
	g_fiche.setAttribute('forced', forced_config);

    g_deleteButton.setAttribute('transform', 'translate(' + (LF - HF * 0.22) + ', 0)');
    g_deleteButton.setAttribute('class', 'clickable');
    g_deleteButton.setAttribute('id', 'deletebtn' + idel);

    g_addsonButton.setAttribute('transform', 'translate(' + LF * 0.5 + ', ' + HF * 0.66 + ') scale(0.33, 0.33)');
    g_addsonButton.setAttribute('class', 'clickable');
    g_addsonButton.setAttribute('id', 'addbtn' + idel);

    r_maincadre.setAttribute('id', 'maincadre' + idel);
    r_maincadre.setAttribute('x', '0');
    r_maincadre.setAttribute('y', '0');
    r_maincadre.setAttribute('rx', '3');
    r_maincadre.setAttribute('ry', '3');
    r_maincadre.setAttribute('width', LF);
    r_maincadre.setAttribute('height', HF);
    if (isnotstart) {
        if (forced_config == 1) {
				r_maincadre.setAttribute('style', 'fill:url(#OrangeDegrade);fill-opacity:0.25;stroke:red;stroke-width:2;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
        } else {
			if (newthread == 1) {
				r_maincadre.setAttribute('style', 'fill:url(#blueDegrade);fill-opacity:0.25;stroke:red;stroke-width:2;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
			} else {
				r_maincadre.setAttribute('style', 'fill:url(#blueDegrade);fill-opacity:0.25;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
			}
            
        }
    } else {
        r_maincadre.setAttribute('style', 'fill:url(#blackDegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
    }

    r_cadredeletebutton.setAttribute('transform', 'scale(0.22, 0.22)');
    r_cadredeletebutton.setAttribute('id', 'cadredeletebtn' + idel);
    r_cadredeletebutton.setAttribute('x', '0');
    r_cadredeletebutton.setAttribute('y', '0');
    r_cadredeletebutton.setAttribute('width', HF);
    r_cadredeletebutton.setAttribute('height', HF);
    r_cadredeletebutton.setAttribute('style', 'fill:#b3b3b3;fill-opacity:0.5008354;stroke:#000000;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');

    p_btnlinkto.setAttribute('transform', 'translate(' + (LF - 5 * HF * 0.2) + ', 1) scale(0.2, 0.2)');
    p_btnlinkto.setAttribute('d', "m 0,0 " + HF + "," + HF / 2 + " -" + HF + " ," + HF / 2 + " z");
    p_btnlinkto.setAttribute('id', 'linkto' + idel);
    p_btnlinkto.setAttribute('class', 'clickable');
    p_btnlinkto.setAttribute('style', "fill:#000000;fill-opacity:0.5008354;stroke:#000000;stroke-width:" + LF / 40 + ";stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1");

    p_btndeleteline.setAttribute('d', "M 0," + HF * 0.2 + " " + HF * 0.2 + ",0");
    p_btndeleteline.setAttribute('style', "fill:none;stroke:#000000;stroke-width:2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    p_btndeletecrossline.setAttribute('d', "m 0,0 " + HF * 0.2 + "," + HF * 0.2 + "");
    p_btndeletecrossline.setAttribute('style', "fill:none;stroke:#000000;stroke-width:2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");


    c_btnlinkfrom.setAttribute('transform', 'translate(' + (LF - 3 * HF * 0.2) + ', 1) scale(0.2, 0.2)');
    c_btnlinkfrom.setAttribute('class', 'clickable');
    c_btnlinkfrom.setAttribute('id', 'linkfrom' + idel);
    c_btnlinkfrom.setAttribute('cx', 0);
    c_btnlinkfrom.setAttribute('cy', HF / 2);
    c_btnlinkfrom.setAttribute('r', HF / 2);
    c_btnlinkfrom.setAttribute('fill', "green");
    c_btnlinkfrom.setAttribute('style', "fill-opacity:0.5008354;stroke:#000000;stroke-width:" + HF / 40 + ";stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    c_forceconfig.setAttribute('transform', 'translate(' + (LF * 0.05) + ', 1) scale(0.2, 0.2)');
    c_forceconfig.setAttribute('class', 'clickable');
    c_forceconfig.setAttribute('id', 'forceconfig' + idel);
    c_forceconfig.setAttribute('cx', 0);
    c_forceconfig.setAttribute('cy', HF / 2);
    c_forceconfig.setAttribute('r', HF / 2);
    c_forceconfig.setAttribute('fill', "grey");
    c_forceconfig.setAttribute('style', "fill-opacity:1;stroke:#000000;stroke-width:" + HF / 20 + ";stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    c_holdunhold.setAttribute('transform', 'translate(' + (LF * 0.05) + ', ' + (HF*0.80) + ') scale(0.2, 0.2)');
    c_holdunhold.setAttribute('class', 'clickable');
    c_holdunhold.setAttribute('id', 'holdunhold' + idel);
    c_holdunhold.setAttribute('cx', 0);
    c_holdunhold.setAttribute('cy', HF / 2);
    c_holdunhold.setAttribute('r', HF / 2);
	if (hold == '1') {
		c_holdunhold.setAttribute('fill', "red");
		title_c_holdunhold.textContent = titre_reactiver;	
		c_holdunhold.appendChild(title_c_holdunhold);
		c_holdunhold.setAttribute('hold', 'true');
	} else {
		c_holdunhold.setAttribute('fill', "green");
		title_c_holdunhold.textContent = titre_desactiver;
		c_holdunhold.appendChild(title_c_holdunhold);
		c_holdunhold.setAttribute('hold', 'false');
	}
    c_holdunhold.setAttribute('style', "fill-opacity:1;stroke:#000000;stroke-width:" + HF / 20 + ";stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");
	
	
    p_btnaddsonline.setAttribute('d', "M 0," + HF * 0.2 + " 0, " + HF * 0.8);
    p_btnaddsonline.setAttribute('style', "fill:none;stroke:#1C6800;stroke-width:" + HF / 6 + ";stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    p_btnaddsoncrossline.setAttribute('d', "m -" + HF * 0.3 + "," + HF / 2 + " " + HF * 0.6 + ",0");
    p_btnaddsoncrossline.setAttribute('style', "fill:none;stroke:#1C6800;stroke-width:" + HF / 6 + ";stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    c_btnaddson.setAttribute('cx', 0);
    c_btnaddson.setAttribute('cy', HF / 2);
    c_btnaddson.setAttribute('r', HF / 2);
    c_btnaddson.setAttribute('fill', "#3DC30C");
    c_btnaddson.setAttribute('style', "fill-opacity:1;stroke:#1C6800;stroke-width:" + HF / 6 + ";stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");



    t_fictitle.setAttribute('id', 'texttitle' + idel);
    t_fictitle.setAttribute('x', '20');
    t_fictitle.setAttribute('y', '10');
    t_fictitle.setAttribute('width', LF * 0.8);
    t_fictitle.setAttribute('height', HF / 3);
    if (hold == '1') {
		t_fictitle.setAttribute('style', "font-style:normal;font-weight:bold;font-size:12px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:red;fill-opacity:1;stroke:none;stroke-width:0.26458332");
	} else {
		t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");
	}
    s_titre = name;
    s_splite_titre = s_titre.split("\n");
    for (var nbl = 0; nbl < s_splite_titre.length; nbl++) {
        var t_span = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
        t_span.setAttribute("name", "tspantexttitle" + idel);
        t_span.textContent = formate_string_svg_t_span(s_splite_titre[nbl]);
        t_fictitle.appendChild(t_span);
        t_span.setAttribute('x', '20');
        t_span.setAttribute('dy', '12');
    }
    ;

    g_deleteButton.appendChild(r_cadredeletebutton);
    g_deleteButton.appendChild(p_btndeleteline);
    g_deleteButton.appendChild(p_btndeletecrossline);
    g_deleteButton.appendChild(title_g_deleteButton);

    g_addsonButton.appendChild(c_btnaddson);
    g_addsonButton.appendChild(p_btnaddsonline);
    g_addsonButton.appendChild(p_btnaddsoncrossline);
    g_addsonButton.appendChild(title_g_btnaddson);

    p_btnlinkto.appendChild(title_p_btnlinkto);
    c_btnlinkfrom.appendChild(title_c_btnlinkfrom);

    c_forceconfig.appendChild(title_c_forceconfig);
    t_gotest.appendChild(title_t_gotest);
	t_newthread.appendChild(title_t_newthread);
	t_samethread.appendChild(title_t_samethread);

    g_fiche.appendChild(r_maincadre);

    g_fiche.appendChild(t_fictitle);
    if (locked == false && screen == "sheetedit") {
        g_fiche.appendChild(c_btnlinkfrom);
        if (isnotstart) {
            c_forceconfig.setAttribute('onclick', "document.getElementById('ojecttypepopuped').value='node_forced_config';document.getElementById('ojectidpopuped').value='';document.getElementById('contentpopup').innerHTML=\"<object id='objpopup' width='99%' data='../node_forced_configs/index?popup=true&sheet_id=" + document.getElementById('sheet_id').value + "&ext_node_id=" + idel + "'></object>\";window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);");
            g_fiche.appendChild(c_forceconfig);
			
            c_holdunhold.setAttribute('onclick', "hold_unhold(" + idel + ")");
            g_fiche.appendChild(c_holdunhold);			
			
            t_gotest.setAttribute('onclick', "document.getElementById('ojecttypepopuped').value='test';document.getElementById('ojectidpopuped').value='" + linkedobj + "';document.getElementById('contentpopup').innerHTML=\"<object id='objpopup' width='99%' data='../tests/edit?write=1&popup=true&test_id=" + linkedobj + "'></object>\";window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);");
            g_fiche.appendChild(t_gotest);

            g_fiche.appendChild(p_btnlinkto);
            g_fiche.appendChild(g_deleteButton);
            g_deleteButton.setAttribute('onclick', 'deleteElement("cadre", "' + 'elG' + idel + '")');
			
			g_fiche.appendChild(t_newthread);
			g_fiche.appendChild(t_samethread);
			t_newthread.setAttribute('onclick', "set_same_thread(" + idel + ")");
			t_samethread.setAttribute('onclick', "set_new_thread(" + idel + ", null)");
			if (newthread == 1) {
				t_samethread.style.display = 'none';
			} else {
				g_fiche.appendChild(t_samethread);
				t_newthread.style.display = 'none';
			}
        }
        g_fiche.appendChild(g_addsonButton);
        g_addsonButton.setAttribute('onclick', 'addElement(' + idel + ', document.getElementById("objtypetoadd").value, document.getElementById("objToLink").value, false, true,"' + screen + '");');
        p_btnlinkto.setAttribute('onclick', 'setLinkToTestSuite("' + idel + '")');
        c_btnlinkfrom.setAttribute('onclick', 'setLinkFrom("' + idel + '")');
    }
    g_fiche.setAttribute('onmousedown', "selectElement(evt, '" + idel + "')");
    if (show) {
        mainG.appendChild(g_fiche);
        s.appendChild(mainG);
        bbox = t_fictitle.getBBox();
        newlf = Math.max(bbox.width + 20, LF);
        newhf = Math.max(bbox.height + 2 * HF / 3, HF);
        if ((newlf > LF) || (newhf > HF)) {
            r_maincadre.setAttribute("width", newlf);
            r_maincadre.setAttribute("height", newhf);
			t_newthread.setAttribute('x', newlf);
			t_samethread.setAttribute('x', newlf);
            g_deleteButton.setAttribute('transform', 'translate(' + (newlf - (HF * 0.22)) + ', 0)');
            p_btnlinkto.setAttribute('transform', 'translate(' + (newlf - 6 * (HF * 0.22)) + ', 1)  scale(0.2, 0.2)');
            c_btnlinkfrom.setAttribute('transform', 'translate(' + (newlf - 3 * (HF * 0.22)) + ', 1)  scale(0.2, 0.2)');
            g_addsonButton.setAttribute('transform', 'translate(' + newlf * 0.5 + ', ' + (newhf - HF * 0.34) + ')  scale(0.33, 0.33)');
        }
    }
}


function newResultSuiteTestElement(idel, matrix, name, objtype, linkedobj, nbpass, nbfail, nbtot, run_id) {
	mainG = document.getElementById("mainG");
	if (mainG == null) {
		var mainG = document.createElementNS('http://www.w3.org/2000/svg', "g");
		mainG.setAttribute('id', 'mainG');
	}
    HF = 40;
    LF = 160;
    isnotstart = true;
    if (objtype == 'starttestsuite') {
        LF = 80;
        isnotstart = false;
    }
    number = idel;
    if (objtype == "testinsuite") {
        splitlinkedobj = linkedobj.split("||*$*||");
        linkedobj = splitlinkedobj[0];
        if (splitlinkedobj.length > 1) {
            name = splitlinkedobj[1];
        }
    }


    var s = document.getElementById('svg');

    var g_fiche = document.createElementNS('http://www.w3.org/2000/svg', "g");

    var r_maincadre = document.createElementNS('http://www.w3.org/2000/svg', "rect");



    var t_fictitle = document.createElementNS('http://www.w3.org/2000/svg', "text");



    g_fiche.setAttribute('transform', matrix);
    g_fiche.setAttribute('class', 'draggable');
    g_fiche.setAttribute('id', 'elG' + idel);
    g_fiche.setAttribute('name', 'elG');
    g_fiche.setAttribute('nodetype', 'card');
    g_fiche.setAttribute('objtype', objtype);
    g_fiche.setAttribute('linkedobj', linkedobj);

    r_maincadre.setAttribute('id', 'maincadre' + idel);
    r_maincadre.setAttribute('x', '0');
    r_maincadre.setAttribute('y', '0');
    r_maincadre.setAttribute('rx', '3');
    r_maincadre.setAttribute('ry', '3');
    r_maincadre.setAttribute('width', LF);
    r_maincadre.setAttribute('height', HF);


    if (isnotstart) {

        //r_maincadre.setAttribute('style', 'fill:url(#vertDegrade10);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
		nbnorun = 0;
		if (parseInt(nbtot) - parseInt(nbpass) - parseInt(nbfail) > 0) {
			nbnorun = parseInt(nbtot) - parseInt(nbpass) - parseInt(nbfail);
		}
        if ((parseInt(nbpass) + parseInt(nbfail)) == 0) {
            r_maincadre.setAttribute('style', 'fill:url(#notrundegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
        } else {
            pourcentpass = parseInt(nbpass) / (parseInt(nbpass) + parseInt(nbfail) + nbnorun) * 100;
			pourcentpassfail = (parseInt(nbpass) + parseInt(nbfail)) / (parseInt(nbpass) + parseInt(nbfail) + nbnorun) * 100;

            r_maincadre.setAttribute('style', 'fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
			linearname = "newlg" + pourcentpass + "-" + pourcentpassfail;
			if (document.getElementById(linearname)) {
			} else {
				var pLinearGradient = document.createElementNS("http://www.w3.org/2000/svg", "linearGradient");
				pLinearGradient.setAttribute("id", linearname);
				document.getElementById("diagdefs").appendChild(pLinearGradient);

				//stops
				var stop1 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
				stop1.setAttribute("id", "stop1" + linearname);
				stop1.setAttribute("offset", pourcentpass + "%");
				stop1.setAttribute("stop-color", "green");
				document.getElementById(linearname).appendChild(stop1);

				var stop2 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
				stop2.setAttribute("id", "stop2" + linearname);
				stop2.setAttribute("offset", pourcentpass + "%");
				stop2.setAttribute("stop-color", "red");
				document.getElementById(linearname).appendChild(stop2);
				
				var stop3 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
				stop3.setAttribute("id", "stop3" + linearname);
				stop3.setAttribute("offset", pourcentpassfail + "%");
				stop3.setAttribute("stop-color", "red");
				document.getElementById(linearname).appendChild(stop3);

				var stop4 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
				stop4.setAttribute("id", "stop4" + linearname);
				stop4.setAttribute("offset", pourcentpassfail + "%");
				stop4.setAttribute("stop-color", "grey");
				document.getElementById(linearname).appendChild(stop4);

				var stop5 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
				stop5.setAttribute("id", "stop3" + linearname);
				stop5.setAttribute("offset", "100%");
				stop5.setAttribute("stop-color", "grey");
				document.getElementById(linearname).appendChild(stop5);
				
			}
            r_maincadre.setAttribute("fill", "url(#" + linearname + ")");
        }

		if (parseInt(nbnorun) > 0) {
			s_titre = "#" + idel + "-" + name + "\nPASS : " + nbpass + " - FAIL : " + nbfail + " - NoRUN : " + nbnorun;
		} else {
			s_titre = "#" + idel + "-" + name + "\nPASS : " + nbpass + " - FAIL : " + nbfail ;
		}
    } else {
        r_maincadre.setAttribute('style', 'fill:url(#blackDegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');

        s_titre = name;
    }


    t_fictitle.setAttribute('id', 'texttitle' + idel);
    t_fictitle.setAttribute('x', '6');
    t_fictitle.setAttribute('y', '10');
    t_fictitle.setAttribute('width', LF * 0.8);
    t_fictitle.setAttribute('height', HF / 3);
    t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");


    s_splite_titre = s_titre.split("\n");
    for (var nbl = 0; nbl < s_splite_titre.length; nbl++) {
        var t_span = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
        t_span.setAttribute("name", "tspantexttitle" + idel);
        t_span.textContent = formate_string_svg_t_span(s_splite_titre[nbl]);
        t_fictitle.appendChild(t_span);
        t_span.setAttribute('x', '6');
        t_span.setAttribute('dy', '12');
        t_fictitle.setAttribute('class', 'clickable');
    }
    ;

    t_fictitle.setAttribute('onclick', "document.getElementById('contentpopup').innerHTML=\"<object id='objpopup' width='99%' data='../run_step_results/index?popup=true&run_id=" + run_id + "&test_node_id_externe=" + idel + "'></object>\";window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);");

    g_fiche.appendChild(r_maincadre);

    g_fiche.appendChild(t_fictitle);

    g_fiche.setAttribute('onmousedown', "selectElement(evt, '" + idel + "')");
    mainG.appendChild(g_fiche);
    s.appendChild(mainG);


    bbox = t_fictitle.getBBox();
    newlf = Math.max(bbox.width + 20, LF);
    newhf = Math.max(bbox.height + HF / 2, HF);
    if ((newlf > LF) || (newhf > HF)) {
        r_maincadre.setAttribute("width", newlf);
        r_maincadre.setAttribute("height", newhf);
    }
}


function newCampainResultSheetElement(idel, matrix, name, objtype, linkedobj, nbpass, nbfail, nbnorun, nbout, campain_id) {
	mainG = document.getElementById("mainG");
	if (mainG == null) {
		var mainG = document.createElementNS('http://www.w3.org/2000/svg', "g");
		mainG.setAttribute('id', 'mainG');
	}
    HF = 40;
    LF = 160;
    isnotstart = true;
    if (objtype == 'starttestsuite') {
        LF = 80;
        isnotstart = false;
    }
    number = idel;
    if (objtype == "testinsuite") {
        splitlinkedobj = linkedobj.split("||*$*||");
        linkedobj = splitlinkedobj[0];
        if (splitlinkedobj.length > 1) {
            name = splitlinkedobj[1];
        }
    }
	if (objtype == "conceptionsheet") {
        splitlinkedobj = linkedobj.split("||*$*||");
        linkedobj = splitlinkedobj[0];
        if (splitlinkedobj.length > 1) {
            name = splitlinkedobj[1];
        }
    }
	if (objtype == "funcscreen") {
        splitlinkedobj = linkedobj.split("||*$*||");
        linkedobj = "";
        if (splitlinkedobj.length == 1) {
            linkedobj = splitlinkedobj[0];
        }
    }
	if (objtype == "existingfuncscreen") {
        objtype = "funcscreen";
        splitlinkedobj = linkedobj.split("||*$*||");
        linkedobj = splitlinkedobj[0];
        if (splitlinkedobj.length > 1) {
            name = splitlinkedobj[1];
        }
    }

    var s = document.getElementById('svg');

    var g_fiche = document.createElementNS('http://www.w3.org/2000/svg', "g");

    var r_maincadre = document.createElementNS('http://www.w3.org/2000/svg', "rect");



    var t_fictitle = document.createElementNS('http://www.w3.org/2000/svg', "text");



    g_fiche.setAttribute('transform', matrix);
    g_fiche.setAttribute('class', 'draggable');
    g_fiche.setAttribute('id', 'elG' + idel);
    g_fiche.setAttribute('name', 'elG');
    g_fiche.setAttribute('nodetype', 'card');
    g_fiche.setAttribute('objtype', objtype);
    g_fiche.setAttribute('linkedobj', linkedobj);

    r_maincadre.setAttribute('id', 'maincadre' + idel);
    r_maincadre.setAttribute('x', '0');
    r_maincadre.setAttribute('y', '0');
    r_maincadre.setAttribute('rx', '3');
    r_maincadre.setAttribute('ry', '3');
    r_maincadre.setAttribute('width', LF);
    r_maincadre.setAttribute('height', HF);


    if (isnotstart) {

        //r_maincadre.setAttribute('style', 'fill:url(#vertDegrade10);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
		if (objtype == "conceptionsheet") {
			r_maincadre.setAttribute('style', 'fill:url(#OrangeDegrade);fill-opacity:0.25;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
		} else {
			if ((parseInt(nbpass) + parseInt(nbfail) + parseInt(nbnorun)) == 0) {
				r_maincadre.setAttribute('style', 'fill:url(#notrundegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
			} else {
				pourcentpass = parseInt(nbpass) / (parseInt(nbpass) + parseInt(nbfail) + parseInt(nbnorun) + parseInt(nbout)) * 100;
				pourcentpassfail = (parseInt(nbpass) + parseInt(nbfail)) / (parseInt(nbpass) + parseInt(nbfail) + parseInt(nbnorun) + parseInt(nbout)) * 100;
				pourcentpassfailnorun = (parseInt(nbpass) + parseInt(nbfail) + parseInt(nbnorun)) / (parseInt(nbpass) + parseInt(nbfail) + parseInt(nbnorun) + parseInt(nbout)) * 100;

				r_maincadre.setAttribute('style', 'fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');

				linearname = "newlg" + pourcentpass + "-" + pourcentpassfail;
				if (document.getElementById(linearname)) {
				} else {
					var pLinearGradient = document.createElementNS("http://www.w3.org/2000/svg", "linearGradient");
					pLinearGradient.setAttribute("id", linearname);
					document.getElementById("diagdefs").appendChild(pLinearGradient);

					//stops
					var stop1 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
					stop1.setAttribute("id", "stop1" + linearname);
					stop1.setAttribute("offset", pourcentpass + "%");
					stop1.setAttribute("stop-color", "green");
					document.getElementById(linearname).appendChild(stop1);

					var stop2 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
					stop2.setAttribute("id", "stop2" + linearname);
					stop2.setAttribute("offset", pourcentpass + "%");
					stop2.setAttribute("stop-color", "red");
					document.getElementById(linearname).appendChild(stop2);
					
					var stop3 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
					stop3.setAttribute("id", "stop3" + linearname);
					stop3.setAttribute("offset", pourcentpassfail + "%");
					stop3.setAttribute("stop-color", "red");
					document.getElementById(linearname).appendChild(stop3);

					var stop4 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
					stop4.setAttribute("id", "stop4" + linearname);
					stop4.setAttribute("offset", pourcentpassfail + "%");
					stop4.setAttribute("stop-color", "yellow");
					document.getElementById(linearname).appendChild(stop4);
					
					var stop5 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
					stop5.setAttribute("id", "stop5" + linearname);
					stop5.setAttribute("offset", pourcentpassfailnorun + "%");
					stop5.setAttribute("stop-color", "yellow");
					document.getElementById(linearname).appendChild(stop5);
					
					var stop6 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
					stop6.setAttribute("id", "stop6" + linearname);
					stop6.setAttribute("offset", pourcentpassfailnorun + "%");
					stop6.setAttribute("stop-color", "grey");
					document.getElementById(linearname).appendChild(stop6);
					
					var stop7 = document.createElementNS("http://www.w3.org/2000/svg", "stop");
					stop7.setAttribute("id", "stop7" + linearname);
					stop7.setAttribute("offset", "100%");
					stop7.setAttribute("stop-color", "grey");
					document.getElementById(linearname).appendChild(stop7);
					
				}
				r_maincadre.setAttribute("fill", "url(#" + linearname + ")");
			}
		}	
		s_titre = "#" + idel + "-" + name 
			if (objtype != "conceptionsheet") {
				s_titre = s_titre + "\nOK : " + nbpass + " - KO : " + nbfail
				if (parseInt(nbnorun) > 0) {
					s_titre += " - no run : " + nbnorun ;
				}
				if (parseInt(nbout) > 0) {
					s_titre += " - out : " + nbout ;
				}
			}
    } else {
        r_maincadre.setAttribute('style', 'fill:url(#blackDegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');

        s_titre = name;
    }


    t_fictitle.setAttribute('id', 'texttitle' + idel);
    t_fictitle.setAttribute('x', '6');
    t_fictitle.setAttribute('y', '10');
    t_fictitle.setAttribute('width', LF * 0.8);
    t_fictitle.setAttribute('height', HF / 3);
    t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");


    s_splite_titre = s_titre.split("\n");
    for (var nbl = 0; nbl < s_splite_titre.length; nbl++) {
        var t_span = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
        t_span.setAttribute("name", "tspantexttitle" + idel);
        t_span.textContent = formate_string_svg_t_span(s_splite_titre[nbl]);
        t_fictitle.appendChild(t_span);
        t_span.setAttribute('x', '6');
        t_span.setAttribute('dy', '12');
        t_fictitle.setAttribute('class', 'clickable');
    }
    ;
	if (objtype == "conceptionsheet") {
		t_fictitle.setAttribute('onclick', 'showDetail("' + idel + '")');
    } else {
		t_fictitle.setAttribute('onclick', "document.getElementById('contentpopup').innerHTML=\"<object id='objpopup' width='99%' data='../procedures/incampain?popup=true&campain_id=" + campain_id + "&&sheet_id=" + document.getElementById('sheetinit').value + "&ext_node_id=" + idel + "'></object>\";window.location.href='#popup';document.getElementById('popup').style.display='block';document.getElementById('objpopup').setAttribute('height', 0.89 * document.body.offsetHeight);");
	}
    g_fiche.appendChild(r_maincadre);

	g_fiche.appendChild(t_fictitle);

    g_fiche.setAttribute('onmousedown', "selectElement(evt, '" + idel + "')");
    mainG.appendChild(g_fiche);
    s.appendChild(mainG);


    bbox = t_fictitle.getBBox();
    newlf = Math.max(bbox.width + 20, LF);
    newhf = Math.max(bbox.height + HF / 2, HF);
    if ((newlf > LF) || (newhf > HF)) {
        r_maincadre.setAttribute("width", newlf);
        r_maincadre.setAttribute("height", newhf);
    }
}


function newWorkflowElement(idel, matrix, name, objtype, locked, show, screen) {
	mainG = document.getElementById("mainG");
	if (mainG == null) {
		var mainG = document.createElementNS('http://www.w3.org/2000/svg', "g");
		mainG.setAttribute('id', 'mainG');
	}
    HF = 40;
    LF = 90;
    isnotstart = true;
    if (objtype == 'startworkflow') {
        isnotstart = false;
    }
    number = idel;
	
    if (name == '') {
        name = titre_node_defaut;
    }

    var s = document.getElementById('svg');
    var g_fiche = document.createElementNS('http://www.w3.org/2000/svg', "g");
    var g_deleteButton = document.createElementNS('http://www.w3.org/2000/svg', "g");
    var g_addsonButton = document.createElementNS('http://www.w3.org/2000/svg', "g");

    var r_maincadre = document.createElementNS('http://www.w3.org/2000/svg', "rect");
    var r_cadredeletebutton = document.createElementNS('http://www.w3.org/2000/svg', "rect");

    var p_btnlinkto = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btndeleteline = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btndeletecrossline = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btnaddsonline = document.createElementNS('http://www.w3.org/2000/svg', "path");
    var p_btnaddsoncrossline = document.createElementNS('http://www.w3.org/2000/svg', "path");

    var c_btnlinkfrom = document.createElementNS('http://www.w3.org/2000/svg', "circle");
    var c_btnaddson = document.createElementNS('http://www.w3.org/2000/svg', "circle");
    var c_endpoint = document.createElementNS('http://www.w3.org/2000/svg', "circle");
	
    var t_fictitle = document.createElementNS('http://www.w3.org/2000/svg', "text");

    var title_g_deleteButton = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_c_btnlinkfrom = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_p_btnlinkto = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_g_btnaddson = document.createElementNS('http://www.w3.org/2000/svg', "title");
    var title_c_endpoint = document.createElementNS('http://www.w3.org/2000/svg', "title");


    title_g_deleteButton.textContent = titre_del_button;
    title_c_btnlinkfrom.textContent = titre_lien_a_partir;
    title_p_btnlinkto.textContent = titre_lien_vers;
    title_g_btnaddson.textContent = titre_ajout_fils;
	title_c_endpoint.textContent = titre_endpoint;

    g_fiche.setAttribute('transform', matrix);
    g_fiche.setAttribute('class', 'draggable');
    g_fiche.setAttribute('id', 'elG' + idel);
    g_fiche.setAttribute('name', 'elG');
    g_fiche.setAttribute('nodetype', 'card');
    g_fiche.setAttribute('objtype', objtype);

    g_deleteButton.setAttribute('transform', 'translate(' + (LF - HF * 0.22) + ', 0)');
    g_deleteButton.setAttribute('class', 'clickable');
    g_deleteButton.setAttribute('id', 'deletebtn' + idel);

    g_addsonButton.setAttribute('transform', 'translate(' + LF * 0.5 + ', ' + HF * 0.66 + ') scale(0.33, 0.33)');
    g_addsonButton.setAttribute('class', 'clickable');
    g_addsonButton.setAttribute('id', 'addbtn' + idel);

    r_maincadre.setAttribute('id', 'maincadre' + idel);
    r_maincadre.setAttribute('x', '0');
    r_maincadre.setAttribute('y', '0');
    r_maincadre.setAttribute('rx', '3');
    r_maincadre.setAttribute('ry', '3');
    r_maincadre.setAttribute('width', LF);
    r_maincadre.setAttribute('height', HF);
    if (isnotstart) {
		if (objtype == 'endpoint') {
        r_maincadre.setAttribute('style', 'fill:url(#vertDegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
		} else {
        r_maincadre.setAttribute('style', 'fill:url(#blueDegrade);fill-opacity:0.25;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
			
		}
    } else {
        r_maincadre.setAttribute('style', 'fill:url(#blackDegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
	}

    r_cadredeletebutton.setAttribute('transform', 'scale(0.22, 0.22)');
    r_cadredeletebutton.setAttribute('id', 'cadredeletebtn' + idel);
    r_cadredeletebutton.setAttribute('x', '0');
    r_cadredeletebutton.setAttribute('y', '0');
    r_cadredeletebutton.setAttribute('width', HF);
    r_cadredeletebutton.setAttribute('height', HF);
    r_cadredeletebutton.setAttribute('style', 'fill:#b3b3b3;fill-opacity:0.5008354;stroke:#000000;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');

    p_btnlinkto.setAttribute('transform', 'translate(' + (LF - 5 * HF * 0.2) + ', 1) scale(0.2, 0.2)');
    p_btnlinkto.setAttribute('d', "m 0,0 " + HF + "," + HF / 2 + " -" + HF + " ," + HF / 2 + " z");
    p_btnlinkto.setAttribute('id', 'linkto' + idel);
    p_btnlinkto.setAttribute('class', 'clickable');
    p_btnlinkto.setAttribute('style', "fill:#000000;fill-opacity:0.5008354;stroke:#000000;stroke-width:" + LF / 40 + ";stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1");

    p_btndeleteline.setAttribute('d', "M 0," + HF * 0.2 + " " + HF * 0.2 + ",0");
    p_btndeleteline.setAttribute('style', "fill:none;stroke:#000000;stroke-width:2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    p_btndeletecrossline.setAttribute('d', "m 0,0 " + HF * 0.2 + "," + HF * 0.2 + "");
    p_btndeletecrossline.setAttribute('style', "fill:none;stroke:#000000;stroke-width:2;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");


    c_btnlinkfrom.setAttribute('transform', 'translate(' + (LF - 3 * HF * 0.2) + ', 1) scale(0.2, 0.2)');
    c_btnlinkfrom.setAttribute('class', 'clickable');
    c_btnlinkfrom.setAttribute('id', 'linkfrom' + idel);
    c_btnlinkfrom.setAttribute('cx', 0);
    c_btnlinkfrom.setAttribute('cy', HF / 2);
    c_btnlinkfrom.setAttribute('r', HF / 2);
    c_btnlinkfrom.setAttribute('fill', "green");
    c_btnlinkfrom.setAttribute('style', "fill-opacity:0.5008354;stroke:#000000;stroke-width:" + HF / 40 + ";stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    c_endpoint.setAttribute('transform', 'translate(' + (LF * 0.05) + ', 1) scale(0.2, 0.2)');
    c_endpoint.setAttribute('class', 'clickable');
    c_endpoint.setAttribute('id', 'forceconfig' + idel);
    c_endpoint.setAttribute('cx', 0);
    c_endpoint.setAttribute('cy', HF / 2);
    c_endpoint.setAttribute('r', HF / 2);
    c_endpoint.setAttribute('fill', "black");
    c_endpoint.setAttribute('style', "fill-opacity:1;stroke:#000000;stroke-width:" + HF / 20 + ";stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");
	
	
    p_btnaddsonline.setAttribute('d', "M 0," + HF * 0.2 + " 0, " + HF * 0.8);
    p_btnaddsonline.setAttribute('style', "fill:none;stroke:#1C6800;stroke-width:" + HF / 6 + ";stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    p_btnaddsoncrossline.setAttribute('d', "m -" + HF * 0.3 + "," + HF / 2 + " " + HF * 0.6 + ",0");
    p_btnaddsoncrossline.setAttribute('style', "fill:none;stroke:#1C6800;stroke-width:" + HF / 6 + ";stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    c_btnaddson.setAttribute('cx', 0);
    c_btnaddson.setAttribute('cy', HF / 2);
    c_btnaddson.setAttribute('r', HF / 2);
    c_btnaddson.setAttribute('fill', "#3DC30C");
    c_btnaddson.setAttribute('style', "fill-opacity:1;stroke:#1C6800;stroke-width:" + HF / 6 + ";stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");

    t_fictitle.setAttribute('id', 'texttitle' + idel);
    t_fictitle.setAttribute('x', '20');
    t_fictitle.setAttribute('y', '10');
    t_fictitle.setAttribute('width', LF * 0.8);
    t_fictitle.setAttribute('height', HF / 3);
    if (name == titre_node_defaut) {
        t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:red;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    } else {
        t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    }


    s_titre = name;
    s_splite_titre = s_titre.split("\n");
    for (var nbl = 0; nbl < s_splite_titre.length; nbl++) {
        var t_span = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
        t_span.setAttribute("name", "tspantexttitle" + idel);
        t_span.textContent = formate_string_svg_t_span(s_splite_titre[nbl]);
        t_fictitle.appendChild(t_span);
        t_span.setAttribute('x', '6');
        t_span.setAttribute('dy', '12');
    }
    ;

    t_fictitle.setAttribute('class', 'clickable');

    g_deleteButton.appendChild(r_cadredeletebutton);
    g_deleteButton.appendChild(p_btndeleteline);
    g_deleteButton.appendChild(p_btndeletecrossline);
    g_deleteButton.appendChild(title_g_deleteButton);

    g_addsonButton.appendChild(c_btnaddson);
    g_addsonButton.appendChild(p_btnaddsonline);
    g_addsonButton.appendChild(p_btnaddsoncrossline);
    g_addsonButton.appendChild(title_g_btnaddson);

    p_btnlinkto.appendChild(title_p_btnlinkto);
    c_btnlinkfrom.appendChild(title_c_btnlinkfrom);
	c_endpoint.appendChild(title_c_endpoint);
	
    g_fiche.appendChild(r_maincadre);

    g_fiche.appendChild(t_fictitle);
    if (locked == false && screen == "sheetedit") {
        g_fiche.appendChild(c_btnlinkfrom);
        if (isnotstart) {
			c_endpoint.setAttribute('onclick', 'setEndPoint("' + idel + '")');
            g_fiche.appendChild(c_endpoint);
            g_fiche.appendChild(p_btnlinkto);
            g_fiche.appendChild(g_deleteButton);
            g_deleteButton.setAttribute('onclick', 'deleteElement("cadre", "' + 'elG' + idel + '")');
        }
        g_fiche.appendChild(g_addsonButton);
        g_addsonButton.setAttribute('onclick', 'addElement(' + idel + ', "status", "", false, true,"' + screen + '");');
        p_btnlinkto.setAttribute('onclick', 'setLinkTo("' + idel + '")');
        c_btnlinkfrom.setAttribute('onclick', 'setLinkFrom("' + idel + '")');
		t_fictitle.setAttribute('onclick', "switchTextToInputWorkflow('elG" + idel + "', 'texttitle" + idel + "', '" + idel + "');");
    }
    g_fiche.setAttribute('onmousedown', "selectElement(evt, '" + idel + "')");
    if (show) {
        mainG.appendChild(g_fiche);
        s.appendChild(mainG);
        bbox = t_fictitle.getBBox();
        newlf = Math.max(bbox.width + 20, LF);
        newhf = Math.max(bbox.height + 2 * HF / 3, HF);
        if ((newlf > LF) || (newhf > HF)) {
            r_maincadre.setAttribute("width", newlf);
            r_maincadre.setAttribute("height", newhf);
            g_deleteButton.setAttribute('transform', 'translate(' + (newlf - (HF * 0.22)) + ', 0)');
            p_btnlinkto.setAttribute('transform', 'translate(' + (newlf - 6 * (HF * 0.22)) + ', 1)  scale(0.2, 0.2)');
            c_btnlinkfrom.setAttribute('transform', 'translate(' + (newlf - 3 * (HF * 0.22)) + ', 1)  scale(0.2, 0.2)');
            g_addsonButton.setAttribute('transform', 'translate(' + newlf * 0.5 + ', ' + (newhf - HF * 0.34) + ')  scale(0.33, 0.33)');
        }
    }
}

function switchTextToInputWorkflow(idFiche, idText, idel) {
    var f_textarea = document.createElementNS('http://www.w3.org/2000/svg', "foreignObject");
    objectmove = true;
    document.getElementById('elG' + idel).setAttribute('onmousedown', "");

    eltorem = document.getElementById(idText);
    //tspans=document.getElementsByName("tspantexttitle"+ idel);
    tspans = document.getElementsByTagName("tspan");
    var innertext = "";
    for (nbl = 0; nbl < tspans.length; nbl++) {
        if (tspans[nbl].getAttribute("name") == "tspantexttitle" + idel) {
            innertext += tspans[nbl].textContent + "\n";
        }
    }
    htmlforeign = innerhtmlstatus.replace('setdynamicdode', "style=\"font-family: Verdana, Geneva, sans-serif;font-size:12px\" id=\"inputtitle" + idel + "\" name=\"inputtitle" + idel + "\" onblur=\"switchInputToTextWorkflow('" + idFiche + "', 'for" + idel + "', 'inputtitle" + idel + "', '" + idText + "', '" + idel + "');\"");
    f_textarea.setAttribute('id', 'for' + idel);
    f_textarea.setAttribute('x', '6');
    f_textarea.setAttribute('y', '10');
    f_textarea.setAttribute('width', LF);
    f_textarea.setAttribute('height', HF);
    f_textarea.innerHTML = htmlforeign;

    eltorem.remove();
    fiche = document.getElementById(idFiche);
    fiche.appendChild(f_textarea);
    document.getElementById("inputtitle" + idel).focus();
}

function switchInputToTextWorkflow(idFiche, idForeign, idSelect, idText, idel) {
    var t_fictitle = document.createElementNS('http://www.w3.org/2000/svg', "text");
    objectmove = false;
    document.getElementById('elG' + idel).setAttribute('onmousedown', "selectElement(evt, '" + idel + "')");

    eltorem = document.getElementById(idForeign);
    eltxtarea = document.getElementById(idSelect);
    t_fictitle.setAttribute('id', idText);
    t_fictitle.setAttribute('x', '20');
    t_fictitle.setAttribute('y', '10');
    t_fictitle.setAttribute('width', LF * 0.8);
    t_fictitle.setAttribute('height', HF / 3);

    s_splite_titre = eltxtarea.value.split("|$|");

    var t_span = document.createElementNS('http://www.w3.org/2000/svg', "tspan");
    t_span.setAttribute("name", "tspantexttitle" + idel);
    t_span.textContent = formate_string_svg_t_span(s_splite_titre[1]);
    t_fictitle.appendChild(t_span);
    t_span.setAttribute('x', '6');
    t_span.setAttribute('dy', '12');

    t_fictitle.setAttribute('class', 'clickable');
    t_fictitle.setAttribute('onclick', "switchTextToInputWorkflow('" + idFiche + "', '" + idText + "', '" + idel + "');");
    t_fictitle.setAttribute('style', "font-style:normal;font-weight:normal;font-size:11px;line-height:1.1;font-family:arial;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");
    eltorem.remove();

    fiche = document.getElementById(idFiche);
    fiche.setAttribute('linkedobj', s_splite_titre[0]);
    fiche.appendChild(t_fictitle);
    majHiddenRepresentation("elG" + idel, "merge", null, true);
    bbox = t_fictitle.getBBox();
        newlf = Math.max(bbox.width + 20, LF);
        newhf = Math.max(bbox.height + 2 * HF / 3, HF);
        if ((newlf > LF) || (newhf > HF)) {
			r_maincadre = document.getElementById("maincadre" + idel);
			g_deleteButton = document.getElementById('deletebtn' + idel);
			g_addsonButton = document.getElementById('addbtn' + idel);
			c_btnlinkfrom = document.getElementById('linkfrom' + idel);
			p_btnlinkto = document.getElementById('linkto' + idel);
            r_maincadre.setAttribute("width", newlf);
            r_maincadre.setAttribute("height", newhf);
            g_deleteButton.setAttribute('transform', 'translate(' + (newlf - (HF * 0.22)) + ', 0)');
            p_btnlinkto.setAttribute('transform', 'translate(' + (newlf - 6 * (HF * 0.22)) + ', 1)  scale(0.2, 0.2)');
            c_btnlinkfrom.setAttribute('transform', 'translate(' + (newlf - 3 * (HF * 0.22)) + ', 1)  scale(0.2, 0.2)');
            g_addsonButton.setAttribute('transform', 'translate(' + newlf * 0.5 + ', ' + (newhf - HF * 0.34) + ')  scale(0.33, 0.33)');
        }
}