/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
var objectmove = false;
var majdatabase = false;
var selectedElement = 0;
var selectedPath = 0;
var nodetype = "";
var linkedobj = "";
var svg = 0;
var currentX = 0;
var currentY = 0;
var currentMatrix = 0;
var s_currentMatrix = "";
var s_initialMatrix = "";
var numelem = 0;
var posX = 0;
var posY = 0;
var cX1 = 0;
var cX2 = 0;
var cY1 = 0;
var cY2 = 0;
var dx = 0;
var dy = 0;

var cadreH = 200;
var cadreL = 160;

var ligneH = 40;
var ligneL = 1000;

var linkfrom = "";

function addElement(id, objtype, objidname, locked, show, screen) {
    majdatabase = true;
    document.getElementById('inflexion_x').value = "";
    document.getElementById('inflexion_y').value = "";
    document.getElementById('curved').value = "";
    var sheetType = document.getElementById('sheet_type').value;

    newMatrix = 'matrix(1 0 0 1 1 1)';
    numelem++;
    traceLine = false;
    if (id != null) {
        currentMatrix = document.getElementById('elG' + id).getAttributeNS(null, "transform").slice(7, -1).split(' ');
        for (var i = 0; i < currentMatrix.length; i++) {
            currentMatrix[i] = parseFloat(currentMatrix[i]);
        }
        fatherX = parseFloat(currentMatrix[4]) + parseFloat(document.getElementById('maincadre' + id).getAttributeNS(null, "x"));
        fatherY = parseFloat(currentMatrix[5]) + parseFloat(document.getElementById('maincadre' + id).getAttributeNS(null, "y"));
        currentMatrix[4] += 100;
        currentMatrix[5] += 100;
        newMatrix = "matrix(" + currentMatrix.join(' ') + ")";
        traceLine = true;
    }
    if (sheetType == 'conception_sheet') {
        newAppElemDesign(numelem, newMatrix, '', objtype, objidname, locked, show, screen);
        majHiddenRepresentation("elG" + numelem, 'merge', id, true);
    }
    if (sheetType == 'test_suite') {
        if (objidname.split('||*$*||').length == 3) {
			newthread = is_new_thread(id, null, objidname.split('||*$*||')[2]);
            newSuiteTestElement(numelem, newMatrix, '', objtype, objidname, locked, show, screen, 0, '0', newthread);
            majHiddenRepresentation("elG" + numelem, 'merge', id, true);
        }
    }
    if (sheetType == 'workflow') {
        newWorkflowElement(numelem, newMatrix, '', objtype, locked, show, screen);
        majHiddenRepresentation("elG" + numelem, 'merge', id, true);
    }

    if (traceLine) {
        mostShortLine(id, numelem, true, locked, null, null, null, null);
    }

}

function mostShortLine(id1, id2, trace, locked, MIDx, MIDy, curved, wait_link) {
	mainG = document.getElementById('mainG');
    elem1 = document.getElementById('elG' + id1);
    elem2 = document.getElementById('elG' + id2);

    line = document.getElementById('link_p' + id1 + '_f' + id2 + '_');
    if (line != null && trace == false && curved == null) {
        curved = parseInt(line.getAttributeNS(null, 'curve'));
        MIDx = parseInt(line.getAttributeNS(null, 'MIDx'));
        MIDy = parseInt(line.getAttributeNS(null, 'MIDy'));
    }


    if (elem1 != null && elem2 != null) {
        var matrix1 = document.getElementById('elG' + id1).getAttributeNS(null, "transform").slice(7, -1).split(' ');
        for (var i = 0; i < matrix1.length; i++) {
            matrix1[i] = parseFloat(matrix1[i]);
        }
        var X1 = parseFloat(matrix1[4]) + parseFloat(document.getElementById('maincadre' + id1).getAttributeNS(null, "x"));
        var Y1 = parseFloat(matrix1[5]) + parseFloat(document.getElementById('maincadre' + id1).getAttributeNS(null, "y"));
        var L1 = parseFloat(document.getElementById('maincadre' + id1).getAttributeNS(null, "width"));
        var H1 = parseFloat(document.getElementById('maincadre' + id1).getAttributeNS(null, "height"));

        var matrix2 = document.getElementById('elG' + id2).getAttributeNS(null, "transform").slice(7, -1).split(' ');
        for (var i = 0; i < matrix2.length; i++) {
            matrix2[i] = parseFloat(matrix2[i]);
        }
        var X2 = parseFloat(matrix2[4]) + parseFloat(document.getElementById('maincadre' + id2).getAttributeNS(null, "x"));
        var Y2 = parseFloat(matrix2[5]) + parseFloat(document.getElementById('maincadre' + id2).getAttributeNS(null, "y"));
        var L2 = parseFloat(document.getElementById('maincadre' + id2).getAttributeNS(null, "width"));
        var H2 = parseFloat(document.getElementById('maincadre' + id2).getAttributeNS(null, "height"));

        if (curved == null || parseInt(curved) == 0) {
            var lgcarre = (X1 + L1 / 2 - X2 - L2 / 2) * (X1 + L1 / 2 - X2 - L2 / 2) + (Y1 + H1 / 2 - Y2 - H2 / 2) * (Y1 + H1 / 2 - Y2 - H2 / 2);
            for (var ix1 = 0; ix1 < 3; ix1++) {
                px1 = X1 + ix1 * L1 / 2;
                for (var ix2 = 0; ix2 < 3; ix2++) {
                    px2 = X2 + ix2 * L2 / 2;
                    for (var iy1 = 0; iy1 < 3; iy1++) {
                        py1 = Y1 + iy1 * H1 / 2;
                        for (var iy2 = 0; iy2 < 3; iy2++) {
                            py2 = Y2 + iy2 * H2 / 2;
                            if (((ix2 == 1 || iy2 == 1) && ix2 + iy2 != 2) && ((ix1 == 1 || iy1 == 1) && ix1 + iy1 != 2) && (((px1 - px2) * (px1 - px2) + (py1 - py2) * (py1 - py2)) < lgcarre)) {
                                lgcarre = (px1 - px2) * (px1 - px2) + (py1 - py2) * (py1 - py2);
                                cX1 = px1;
                                cX2 = px2;
                                cY1 = py1;
                                cY2 = py2;
                            }
                        }
                    }
                }
            }
            Ix = cX1 + (cX2 - cX1) / 2;
            Iy = cY1 + (cY2 - cY1) / 2;
            MIDx = Ix;
            MIDy = Iy;
            if (line != null) {
                line.setAttributeNS(null, 'Ix', Ix);
                line.setAttributeNS(null, 'Iy', Iy);
                line.setAttributeNS(null, 'MIDx', MIDx);
                line.setAttributeNS(null, 'MIDy', MIDy);
                line.setAttributeNS(null, 'curve', 0);
            }
        } else {
            line = document.getElementById('link_p' + id1 + '_f' + id2 + '_');
            var lgcarre1 = (X1 + L1 / 2 - MIDx) * (X1 + L1 / 2 - MIDx) + (Y1 + H1 / 2 - MIDy) * (Y1 + H1 / 2 - MIDy);
            var lgcarre2 = (MIDx - X2 - L2 / 2) * (MIDx - X2 - L2 / 2) + (MIDy - Y2 - H2 / 2) * (MIDy - Y2 - H2 / 2);
            for (var ix1 = 0; ix1 < 3; ix1++) {
                px1 = X1 + ix1 * L1 / 2;
                for (var ix2 = 0; ix2 < 3; ix2++) {
                    px2 = X2 + ix2 * L2 / 2;
                    for (var iy1 = 0; iy1 < 3; iy1++) {
                        py1 = Y1 + iy1 * H1 / 2;
                        for (var iy2 = 0; iy2 < 3; iy2++) {
                            py2 = Y2 + iy2 * H2 / 2;
                            if (((ix2 == 1 || iy2 == 1) && ix2 + iy2 != 2) && ((ix1 == 1 || iy1 == 1) && ix1 + iy1 != 2) && (((px1 - MIDx) * (px1 - MIDx) + (py1 - MIDy) * (py1 - MIDy) + (MIDx - px2) * (MIDx - px2) + (MIDy - py2) * (MIDy - py2)) < lgcarre1 + lgcarre2)) {
                                lgcarre1 = (px1 - MIDx) * (px1 - MIDx) + (py1 - MIDy) * (py1 - MIDy);
                                lgcarre2 = (MIDx - px2) * (MIDx - px2) + (MIDy - py2) * (MIDy - py2);
                                cX1 = px1;
                                cX2 = px2;
                                cY1 = py1;
                                cY2 = py2;
                                Ix = 2 * MIDx - cX1 / 2 - cX2 / 2;
                                Iy = 2 * MIDy - cY1 / 2 - cY2 / 2;
                                if (line != null) {
                                    line.setAttributeNS(null, 'Ix', Ix);
                                    line.setAttributeNS(null, 'Iy', Iy);
                                    line.setAttributeNS(null, 'MIDx', MIDx);
                                    line.setAttributeNS(null, 'MIDy', MIDy);
                                    line.setAttributeNS(null, 'curve', 1);
                                }
                            }
                        }
                    }
                }
            }
        }


        if (trace) {
            //var s = document.getElementById('svg');
            var line = document.createElementNS('http://www.w3.org/2000/svg', "path");
            var c_middle = document.createElementNS('http://www.w3.org/2000/svg', "circle");
            line.setAttribute('typepath', 'link');
            line.setAttribute('id', 'link_p' + id1 + '_f' + id2 + '_');
            line.setAttribute('name', 'lien');
            line.setAttribute('d', 'M ' + cX1 + ' ' + cY1 + ' Q ' + Ix + ' ' + Iy + ' ' + cX2 + ' ' + cY2);
            line.setAttribute('stroke-width', "2");
            line.setAttribute('stroke', "black");
			if (wait_link == "1") {
				line.setAttribute('stroke-dasharray', '5,5');
			}
            line.setAttribute('fill', "none");
            line.setAttribute('idpere', id1);
            line.setAttribute('idfils', id2);
            line.setAttribute('Ix', Ix);
            line.setAttribute('Iy', Iy);
            line.setAttribute('MIDx', MIDx);
            line.setAttribute('MIDy', MIDy);
			line.setAttribute('waitlink', wait_link);
            if (curved != null && curved == 1) {
                line.setAttribute('curve', 1);
            } else {
                line.setAttribute('curve', 0);
            }
            line.setAttribute('marker-start', "url(#circlehead)");
            line.setAttribute('marker-middle', "url(#circlemid)");
            line.setAttribute('marker-end', "url(#arrowhead)");
            line.setAttribute('class', 'deletable');
            mainG.appendChild(line);
            c_middle.setAttribute('class', 'clickable');
            c_middle.setAttribute('id', 'midlink_p' + id1 + '_f' + id2 + '_');
            c_middle.setAttribute('cx', MIDx)
            c_middle.setAttribute('cy', MIDy);
            c_middle.setAttribute('r', 5);
            c_middle.setAttribute('fill', "blue");
            c_middle.setAttribute('style', "fill-opacity:0.5008354;stroke:#000000;stroke-width:1;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1");
            c_middle.setAttribute('onmousedown', "selectInflexionCircle(evt, 'link_p" + id1 + "_f" + id2 + "_', " + id1 + ", " + id2 + ")");
            mainG.appendChild(c_middle);

            if (locked == false) {
                line.setAttribute('onclick', 'deleteElement("lien", "' + 'link_p' + id1 + '_f' + id2 + '_' + '")');
            }
            mainG.appendChild(line);

        }
    }
}

function deleteElement(quoi, id) {
  if (confirm(supprimer_noeud)) {
    var el = document.getElementById(id);
    nodetype = el.getAttribute("nodetype");
    majHiddenRepresentation(id, "delete", ligneH + 10, true);
    el.remove();
    if (document.getElementById("mid" + id) != null) {
        document.getElementById("mid" + id).remove();
    }
    if (quoi == "cadre") {
        var idid = id.replace("elG", "");
        var lines = document.getElementsByTagName("path");
        var lineToDelete = [];
        for (var i = 0; i < lines.length; i++) {
            idfils = lines[i].getAttributeNS(null, "idfils");
            idpere = lines[i].getAttributeNS(null, "idpere");
            if (idfils != null && idpere != null) {
                if ((idfils == idid) || (idpere == idid)) {
                    lineToDelete.push(lines[i].getAttributeNS(null, "id"));
                }
            }
        }
        for (var i = 0; i < lineToDelete.length; i++) {
            document.getElementById(lineToDelete[i]).remove();
            if (document.getElementById("mid" + lineToDelete[i]) != null) {
                document.getElementById("mid" + lineToDelete[i]).remove();
            }
        }
        if (nodetype == "line") {
            ordonneV(null);
        }
    }
  }
}

function setLinkFrom(id) {
    if (id == linkfrom) {
        document.getElementById("linkfrom" + id).setAttribute('fill', "green");
        linkfrom = "";
    } else {
        if (linkfrom != "") {
            document.getElementById("linkfrom" + linkfrom).setAttribute('fill', "green");
        }
        document.getElementById("linkfrom" + id).setAttribute('fill', "red");
        linkfrom = id;
    }
}

function setLinkTo(id) {
    if (linkfrom != "" && linkfrom != id && document.getElementById('link_p' + linkfrom + '_f' + id + '_') == null) {
        mostShortLine(linkfrom, id, true, false, null, null, null, null);
        majHiddenRepresentation('link_p' + linkfrom + '_f' + id + '_', 'merge', null, true);
    }
}



function selectElement(evt, idEl) {
    objectmove = true;
    svg = document.getElementById('svg');
    selectedElement = document.getElementById('elG' + idEl);
    currentX = evt.clientX;
    currentY = evt.clientY;
    s_initialMatrix = selectedElement.getAttributeNS(null, "transform");
    currentMatrix = selectedElement.getAttributeNS(null, "transform").slice(7, -1).split(' ');
    for (var i = 0; i < currentMatrix.length; i++) {
        currentMatrix[i] = parseFloat(currentMatrix[i]);
    }
    svg.setAttributeNS(null, "onmousemove", "moveElement(evt, " + idEl + ")");
    svg.setAttributeNS(null, "onmouseup", "deselectElement(evt)");
    selectedElement.setAttributeNS(null, "onclick", "deselectElement(evt)");
}

function moveElement(evt, idEl) {
    nodetype = selectedElement.getAttribute("nodetype");
    dx = evt.clientX - currentX;
    dy = evt.clientY - currentY;
    if (nodetype == "card") {
        currentMatrix[4] += dx;
    } else {
        currentMatrix[4] = 1;
    }
    currentMatrix[5] += dy;
    newMatrix = "matrix(" + currentMatrix.join(' ') + ")";

    selectedElement.setAttributeNS(null, "transform", newMatrix);
    currentX = evt.clientX;
    currentY = evt.clientY;

    var lines = document.getElementsByTagName("path");
    for (var i = 0; i < lines.length; i++) {
        nameLine = lines[i].getAttributeNS(null, "id");
        if (nameLine != null && nameLine.indexOf('p' + idEl + '_') > 0) {
            idfils = lines[i].getAttributeNS(null, "idfils");
            mostShortLine(idEl, idfils, false, false, null, null, null, null);
            Ix = parseInt(lines[i].getAttributeNS(null, "Ix"));
            Iy = parseInt(lines[i].getAttributeNS(null, "Iy"));
            lines[i].setAttributeNS(null, 'd', 'M ' + cX1 + ' ' + cY1 + ' Q ' + Ix + ' ' + Iy + ' ' + cX2 + ' ' + cY2);
            c_middle = document.getElementById("mid" + nameLine);
            MIDx = Ix + (cX1 - Ix) / 2 + ((cX2 - Ix) / 2 - (cX1 - Ix) / 2) / 2;
            MIDy = Iy + (cY1 - Iy) / 2 + ((cY2 - Iy) / 2 - (cY1 - Iy) / 2) / 2;
            c_middle.setAttributeNS(null, 'cx', MIDx);
            c_middle.setAttributeNS(null, 'cy', MIDy);
        }
        if (nameLine != null && nameLine.indexOf('f' + idEl + '_') > 0) {
            idpere = lines[i].getAttributeNS(null, "idpere");
            mostShortLine(idpere, idEl, false, false, null, null, null, null);
            Ix = parseInt(lines[i].getAttributeNS(null, "Ix"));
            Iy = parseInt(lines[i].getAttributeNS(null, "Iy"));
            lines[i].setAttributeNS(null, 'd', 'M ' + cX1 + ' ' + cY1 + ' Q ' + Ix + ' ' + Iy + ' ' + cX2 + ' ' + cY2);
            c_middle = document.getElementById("mid" + nameLine);
            MIDx = Ix + (cX1 - Ix) / 2 + ((cX2 - Ix) / 2 - (cX1 - Ix) / 2) / 2;
            MIDy = Iy + (cY1 - Iy) / 2 + ((cY2 - Iy) / 2 - (cY1 - Iy) / 2) / 2;
            c_middle.setAttributeNS(null, 'cx', MIDx);
            c_middle.setAttributeNS(null, 'cy', MIDy);
        }
    }

}

function deselectElement(evt) {
    objectmove = false;
    if (selectedElement != 0) {
        svg.removeAttributeNS(null, "onmousemove");
        selectedElement.removeAttributeNS(null, "onmouseout");
        svg.removeAttributeNS(null, "onmouseup");
        selectedElement.removeAttributeNS(null, "onclick");

        if (nodetype == "line") {
            ordonneV(selectedElement.getAttribute("id"));
        } else {
            if (s_initialMatrix != selectedElement.getAttributeNS(null, "transform")) {
                majHiddenRepresentation(selectedElement.getAttributeNS(null, "id"), "merge", null, true);
            }
        }

        selectedElement = 0;
    }
}



function majHiddenRepresentation(elemid, what, idpere, async) {
    if (majdatabase) {
        repstring = "";
        //var gs = document.getElementsByName("elG"); marche pas sur ffox
        var gs = document.getElementsByTagName("g");
        for (var i = 0; i < gs.length; i++) {
            if (gs[i].getAttribute("name") == "elG") {
                id = gs[i].getAttributeNS(null, "id").replace("elG", "");
                nodetype = gs[i].getAttribute("nodetype");
                objtype = gs[i].getAttribute("objtype");
                linkedobj = gs[i].getAttribute("linkedobj");
                matrice = gs[i].getAttributeNS(null, "transform").slice(7, -1).split(' ');
                for (var im = 0; im < matrice.length; im++) {
                    matrice[im] = parseFloat(matrice[im]);
                }
                x = matrice[4];
                y = matrice[5];
                //tspans=document.getElementsByName("tspantexttitle" + id);
                tspans = document.getElementsByTagName("tspan");
                var title = "";
                for (nbl = 0; nbl < tspans.length; nbl++) {
                    if (tspans[nbl].getAttribute("name") == "tspantexttitle" + id) {
                        title += tspans[nbl].textContent + "\n";
                    }
                }
                repstring += "replace;element;" + id + ";" + x + ";" + y + ";" + title + "\n";
                if (("elG" + id) == elemid) {
                    document.getElementById("do3").value = what;
                    document.getElementById("obj").value = "node";
                    document.getElementById("idext").value = id;
                    document.getElementById("nodetype").value = nodetype;
                    document.getElementById("objtype").value = objtype;
                    document.getElementById("linkedobj").value = linkedobj;
                    document.getElementById("x").value = x;
                    document.getElementById("y").value = y;
                    if (idpere == null) {
                        document.getElementById("father").value = "";
                        document.getElementById("son").value = "";
                    } else {
                        document.getElementById("father").value = idpere;
                        document.getElementById("son").value = id;
                    }
                    document.getElementById("title").value = title;
					if (document.getElementById("newthread")) {
						document.getElementById("newthread").value = gs[i].getAttribute("newthread");
					}
					if (document.getElementById("waitlink")) {
						document.getElementById("waitlink").value = 0;
					}
                    document.getElementById("lastupdate").submit();
                }
            }
        }

        var liens = document.getElementsByTagName("path");
        repstring += "suite";
        for (var i = 0; i < liens.length; i++) {
            if (liens[i].getAttributeNS(null, "typepath") != null && liens[i].getAttributeNS(null, "typepath") == 'link') {
                repstring += "suite";
                pere = liens[i].getAttributeNS(null, "idpere");
                fils = liens[i].getAttributeNS(null, "idfils");
                inflexion_x = liens[i].getAttributeNS(null, "MIDx");
                inflexion_y = liens[i].getAttributeNS(null, "MIDy");
                curved = liens[i].getAttributeNS(null, "curve");
                repstring += "replace;lien;" + pere + ";" + fils + "\n";
                if (liens[i].getAttributeNS(null, "id") == elemid) {
                    document.getElementById("do3").value = what;
                    document.getElementById("obj").value = "link";
                    document.getElementById("idext").value = elemid;
                    document.getElementById("x").value = "";
                    document.getElementById("y").value = "";
                    document.getElementById("father").value = pere;
                    document.getElementById("son").value = fils;
                    document.getElementById("title").value = "";
                    document.getElementById("inflexion_x").value = inflexion_x;
                    document.getElementById("inflexion_y").value = inflexion_y;
                    document.getElementById("curved").value = curved;
					if (document.getElementById("waitlink")) {
						document.getElementById("waitlink").value = liens[i].getAttribute("waitlink");
					}
                    document.getElementById("lastupdate").submit();
                }
            }
        }

        document.getElementById("representation").value = repstring;
    }
}







function ordonneV(idElemMoved) {
    istart = ligneH + 100;
    var gs = document.getElementsByTagName("g");
    var tgs = [];
    for (var i = 0; i < gs.length; i++) {
        gsMatrix = gs[i].getAttributeNS(null, "transform").slice(7, -1).split(' ');
        for (var im = 0; im < currentMatrix.length; im++) {
            gsMatrix[im] = parseFloat(gsMatrix[im]);
        }
        var elem = {id: gs[i].getAttributeNS(null, "id"), posy: gsMatrix[5]};
        tgs.push(elem);
    }

    tgs.sort(function (a, b) {
        return a.posy - b.posy;
    });

    for (var i = 0; i < tgs.length; i++) {
        var gsi = document.getElementById(tgs[i].id);
        gsMatrix = gsi.getAttributeNS(null, "transform").slice(7, -1).split(' ');
        for (var im = 0; im < currentMatrix.length; im++) {
            gsMatrix[im] = parseFloat(gsMatrix[im]);
        }
        gsMatrix[4] = 1;
        gsMatrix[5] = istart.toString();
        istart = istart + 10 + ligneH;
        newMatrix = "matrix(" + gsMatrix.join(' ') + ")";
        gsi.setAttributeNS(null, "transform", newMatrix);
    }
    if (idElemMoved != null) {
        for (var i = 0; i < tgs.length; i++) {
            if (tgs[i].id == idElemMoved) {
                majHiddenRepresentation(tgs[i].id, "move", 10 + ligneH, true);
            }
        }
    }
}

function showDetail(idel) {
    elG = document.getElementById("elG" + idel);
    objtype = elG.getAttribute("objtype");
    linkedobj = elG.getAttribute("linkedobj");
    if (objtype == "conceptionsheet") {
        document.getElementById("redirsheet").value = linkedobj;
        startloader();
        document.getElementById("formredirsheet").submit();
    }

}





var startX;
var startY;
function startmoveallsvg(evt) {
    if (objectmove == false) {
        if (document.selection) {
            document.selection.empty();
        } else if (window.getSelection) {
            window.getSelection().removeAllRanges();
        }
        startX = evt.clientX;
        startY = evt.clientY;
        document.getElementById('wrapper2').setAttribute("onmouseup", "deselectallsvg(event)");
        document.getElementById('wrapper2').setAttribute("onmousemove", "moveallsvg(event)");
        document.getElementById('wrapper2').setAttribute("onmousedown", "");
    }
}
function moveallsvg(evt) {
    document.getElementById('wrapper2').scrollTop = document.getElementById('wrapper2').scrollTop - evt.clientY + startY;
    document.getElementById('wrapper2').scrollLeft = document.getElementById('wrapper2').scrollLeft - evt.clientX + startX;
    document.getElementById('wrapper1').scrollLeft = document.getElementById('wrapper1').scrollLeft - evt.clientX + startX;
    startX = evt.clientX;
    startY = evt.clientY;
}
function deselectallsvg(evt) {
    document.getElementById('wrapper2').scrollTop = document.getElementById('wrapper2').scrollTop - evt.clientY + startY;
    document.getElementById('wrapper2').scrollLeft = document.getElementById('wrapper2').scrollLeft - evt.clientX + startX;
    document.getElementById('wrapper1').scrollLeft = document.getElementById('wrapper1').scrollLeft - evt.clientX + startX;

    document.getElementById('wrapper2').setAttribute("onmouseup", "");
    document.getElementById('wrapper2').setAttribute("onmousemove", "");
    document.getElementById('wrapper2').setAttribute("onmousedown", "startmoveallsvg(event)");
}



function selectInflexionCircle(evt, idEl, id1, id2) {
    objectmove = true;
    svg = document.getElementById('svg');
    selectedElement = document.getElementById('mid' + idEl);
    selectedPath = document.getElementById(idEl);
    selectedPath.setAttribute('curve', '1');
    mostShortLine(id1, id2, false, false, null, null, null, null);
    svg.setAttributeNS(null, "onmousemove", "moveInflexionCircle(evt, " + idEl + ", " + id1 + ", " + id2 + ")");
    svg.setAttributeNS(null, "onmouseup", "deselectInflexionCircle(evt, '" + idEl + "')");
    selectedElement.setAttributeNS(null, "onclick", "deselectInflexionCircle(evt, '" + idEl + "')");
    dx = selectedElement.getAttributeNS(null, 'cx') - evt.clientX;
    dy = selectedElement.getAttributeNS(null, 'cy') - evt.clientY;
}

function moveInflexionCircle(evt, idEl, id1, id2) {
    MIDx = evt.clientX + dx;
    MIDy = evt.clientY + dy;
    selectedElement.setAttributeNS(null, 'cx', MIDx);
    selectedElement.setAttributeNS(null, 'cy', MIDy);
    mostShortLine(id1, id2, false, false, MIDx, MIDy, '1', null);
    Ix = parseInt(selectedPath.getAttributeNS(null, "Ix"));
    Iy = parseInt(selectedPath.getAttributeNS(null, "Iy"));
    selectedPath.setAttributeNS(null, 'd', 'M ' + cX1 + ' ' + cY1 + ' Q ' + Ix + ' ' + Iy + ' ' + cX2 + ' ' + cY2);
}

function deselectInflexionCircle(evt, idEl) {
    objectmove = false;
    if (selectedElement != 0) {
        svg.removeAttributeNS(null, "onmousemove");
        selectedElement.removeAttributeNS(null, "onmouseout");
        svg.removeAttributeNS(null, "onmouseup");
        selectedElement.removeAttributeNS(null, "onclick");
        majHiddenRepresentation(idEl, 'merge', null, true);
        selectedElement = 0;
    }
}

function setEndPoint(id) {
	objtype = document.getElementById("elG" + id).getAttribute('objtype');
	if (objtype == 'status') {
		document.getElementById("elG" + id).setAttribute('objtype', 'endpoint');
		document.getElementById("maincadre" + id).setAttribute('style', 'fill:url(#vertDegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
	} else {
		document.getElementById("elG" + id).setAttribute('objtype', 'status');
		document.getElementById("maincadre" + id).setAttribute('style', 'fill:url(#blueDegrade);fill-opacity:1;stroke:#000000;stroke-width:0.5;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1');
	}
    majHiddenRepresentation("elG" + id, "merge", null, true);

	}


function is_new_thread(numpere, numfils, typetest) {
	var newthread = 0;
	if (numfils != null) {
		typetest = document.getElementById("elG" + numfils).getAttribute("testtype");
	}
	typetestpere = document.getElementById("elG" + numpere).getAttribute("testtype");

	// si les types pere et fils sont différents on déclenche forcément un nouveau thread
	if (typetest != typetestpere) {
		newthread = 1;
	} else {
	//quand le pere a deja un fils on mets directement un nouveau thread
		if (document.getElementById("elG" + numpere).getAttribute("objtype") == "starttestsuite") {
			newthread = 1;
		} else {
			var liens = document.getElementsByTagName("path");
			for (var i = 0; i < liens.length; i++) {
				pere = liens[i].getAttributeNS(null, "idpere");
				fils = liens[i].getAttributeNS(null, "idfils");
				if (pere == numpere && (numfils == null || (numfils != fils && document.getElementById("elG" + fils).getAttribute("newthread") == "0"))) {
					newthread = 1;
					break;
				}
			}
		}
	}
	return newthread;

}

function set_new_thread(idel, pere) {
	document.getElementById("newthread" + idel).style.display = "block";
	document.getElementById("samethread" + idel).style.display = "none";
	document.getElementById("maincadre" + idel).style.stroke = "red";
	document.getElementById("maincadre" + idel).style.setProperty("stroke-width", "2");
	document.getElementById("elG" + idel).setAttribute("newthread", "1");
	majHiddenRepresentation("elG" + idel, "merge", pere, true);
}


function hold_unhold(idel) {
	elem = document.getElementById("holdunhold" + idel);
	is_hold = elem.getAttribute("hold");
	if (is_hold == "true") {
		elem.setAttribute('fill', "green");
		document.getElementById("titlehold" + idel).textContent = titre_desactiver;
		document.getElementById("texttitle" + idel).setAttribute('style', "font-style:normal;font-weight:normal;font-size:12px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:black;fill-opacity:1;stroke:none;stroke-width:0.26458332");
		elem.setAttribute('hold', 'false');
	} else {
		elem.setAttribute('fill', "red");
		document.getElementById("titlehold" + idel).textContent = titre_reactiver;
		document.getElementById("texttitle" + idel).setAttribute('style', "font-style:normal;font-weight:bold;font-size:12px;line-height:1.25;font-family:sans-serif;letter-spacing:0px;word-spacing:0px;fill:red;fill-opacity:1;stroke:none;stroke-width:0.26458332");
		elem.setAttribute('hold', 'true');
	}
	document.getElementById("hold_node_id").value = idel;
	document.getElementById("hold_value").value = elem.getAttribute('hold');
	document.getElementById("holdunholdform").submit();
}

function set_same_thread(idel) {
	fils_de_de_start = false;
	nb_brother_st = 0;
	can_switch = true;
	fathers = "";
	nbfathers = 0;
	testtype = document.getElementById("elG" + idel).getAttribute("testtype");
	var liens = document.getElementsByTagName("path");
	// on recherche les pères, si c'est le startnode, ou de type different, ou forcé impossible de switcher
	if (document.getElementById("elG" + idel).getAttribute("forced") == "1") {
		can_switch = false;
		alert(impossible_noeud_force);
	} else {
		for (var i = 0; i < liens.length; i++) {
			fils = liens[i].getAttributeNS(null, "idfils");
			if (fils == idel) {
				pere = liens[i].getAttributeNS(null, "idpere");
				fathers += pere + ";";
				nbfathers += 1;
				if (document.getElementById("elG" + pere).getAttribute("objtype") == "starttestsuite") {
					can_switch = false;
					alert(impossible_fils_de_start);
					break;
				}
				if (typetest = document.getElementById("elG" + pere).getAttribute("testtype") != testtype) {
					can_switch = false;
					alert(impossible_pere_type_different);
					break;
				}
			}
		}
	}
	// on vérifie que les pères n'ont pas un autre fils dans la même session
	if (can_switch) {
		father = fathers.split(";");
		for (j = 0;j < nbfathers;j++) {
			for (var i = 0; i < liens.length; i++) {
				pere = liens[i].getAttributeNS(null, "idpere");
				if (pere == father[j]) {
					fils = liens[i].getAttributeNS(null, "idfils");
					if (fils != idel) {
						if (document.getElementById("elG" + fils).getAttribute("newthread") == "0" && (liens[i].getAttribute("waitlink") != "1")) {
							can_switch = false;
							alert(impossible_frere_deja_same_thread);
							break;
						}
					}
				}
			}
		}
	}
	if (can_switch) {
		document.getElementById("newthread" + idel).style.display = "none";
		document.getElementById("samethread" + idel).style.display = "block";
		document.getElementById("maincadre" + idel).style.stroke = "#000000";
		document.getElementById("maincadre" + idel).style.setProperty("stroke-width", "0.5");
		document.getElementById("elG" + idel).setAttribute("newthread", "0");
		majHiddenRepresentation("elG" + idel, "merge", null, true);
	}
}

function setLinkToTestSuite(id) {
	cantaddlien = is_circuit_ferme(linkfrom, id);
	if (cantaddlien) {
		alert(impossible_circuit_ferme);
	}
    if (!cantaddlien && linkfrom != "" && linkfrom != id && document.getElementById('link_p' + linkfrom + '_f' + id + '_') == null) {
		has_another_f = has_another_father(id);
		if (is_new_thread(linkfrom, id, null) == 1 && has_another_f != 1) {
			mostShortLine(linkfrom, id, true, false, null, null, null, has_another_f);
			set_new_thread(id, linkfrom);
		} else {
			mostShortLine(linkfrom, id, true, false, null, null, null, has_another_f);
			majHiddenRepresentation('link_p' + linkfrom + '_f' + id + '_', 'merge', null, true);
		}
    }
}


function is_circuit_ferme(linkfrom, linkto) {
	circuitferme = false;
	listefils = get_all_sons(linkto, ";");
	if (listefils.indexOf(";" + linkfrom + ";") >= 0) {
		circuitferme = true
	}
	if (circuitferme == false) {
		listefils = get_all_sons(linkfrom, ";");
		if (listefils.indexOf(";" + linkto + ";") >= 0) {
			circuitferme = true
		}
	}
	return circuitferme;
}

function has_another_father(linkto) {
	var has_another = 0;
	var liens = document.getElementsByTagName("path");
	for (var i = 0; i < liens.length; i++) {
		if (liens[i].getAttributeNS(null, "idfils") == linkto) {
			has_another = 1;
			break;
		}
	}
	return has_another;
}


function get_all_sons(pere, listefils) {
	var liens = document.getElementsByTagName("path");
	for (var i = 0; i < liens.length; i++) {
		if (liens[i].getAttributeNS(null, "idpere") == pere) {
			listefils += liens[i].getAttributeNS(null, "idfils") + ";";
			listefils = get_all_sons(liens[i].getAttributeNS(null, "idfils"), listefils);
		}
	}
	return listefils;
}

function animatestartednode(id) {
	svg = document.getElementById('svg');
	elem = document.getElementById('maincadre' + id);
	var ani = document.createElementNS("http://www.w3.org/2000/svg","animateTransform");
	ani.setAttribute("dur", "1s");
	ani.setAttribute("xlink:href", "#elG" + id);
	ani.setAttribute("attributeName", "transform");
    ani.setAttribute("type", "scale");
    ani.setAttribute("from", "1");
    ani.setAttribute("to", "1.05");
    ani.setAttribute("begin", "0s");
    ani.setAttribute("dur", "0.5s");
	ani.setAttribute("fill", "freeze");
	ani.setAttribute("repeatCount", "indefinite");
	elem.appendChild(ani);
}
