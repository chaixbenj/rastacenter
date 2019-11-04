/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
String.prototype.replaceAt=function(index, replacement) {
    return this.substr(0, index) + replacement+ this.substr(index + replacement.length);
};

function buildRightsString() {
    rightscb = document.getElementsByName("droit");
    stringdroits = "000000000000000000000000000000000000000000000000";

    for (i = 0; i < rightscb.length; i++) {
        if (rightscb[i].checked) {
            
            idx = parseInt(rightscb[i].id.replace("droit", ""));
            stringdroits = stringdroits.replaceAt(idx, "1");
        }
    }

    document.getElementById('droits').value = stringdroits;

}