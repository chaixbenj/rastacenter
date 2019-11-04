/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


function addConfigurationVariableValue(n) {
    nbvalue = parseInt(document.getElementById("nbvalue").value) + 1;
    document.getElementById("nbvalue").value = nbvalue;
    var tr = n.parentNode.parentNode.cloneNode(true);
    tr.innerHTML = "<tr><td colspan=\"2\"><input onKeyUp=\"formatslash(this);\"  onchange=\"showvalidbtn();\"  name=\"varvalue" + nbvalue + "\" type=\"text\" class=\"inputbox\" placeholder=\"valeur\" size=\"50\" maxlength=\"150\"/></td></tr>";
    document.getElementById('vartable').appendChild(tr);
}

