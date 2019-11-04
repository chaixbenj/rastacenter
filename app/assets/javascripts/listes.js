/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


function addListeValue(n) {
    nbvalue = parseInt(document.getElementById("nbvalue").value) + 1;
    document.getElementById("nbvalue").value = nbvalue;
    var tr = n.parentNode.parentNode.cloneNode(true);
    tr.innerHTML = "<tr><td colspan=\"2\"><input onchange=\"showvalidbtn();\"  name=\"varvalue" + nbvalue +"\" type=\"text\" class=\"inputbox\" placeholder=\"valeur\" maxlength=\"50\" size=\"50\"/></td></tr>";
    document.getElementById('vartable').appendChild(tr);
}

