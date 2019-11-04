/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */



function showHideRelease(element) {
	
	releasedisplayed = localStorage.getItem("alfyftreleasedisplayed");
	if (releasedisplayed == null) {localStorage.setItem("alfyftreleasedisplayed","");releasedisplayed = localStorage.getItem("alfyftreleasedisplayed");}
    deplie = document.getElementById("signe" + element).innerHTML;
    if (deplie == "<b>+&nbsp;&nbsp;</b>") {
        elements = document.getElementsByName(element);
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'inline-block';
        }
        document.getElementById("signe" + element).innerHTML = "<b>-&nbsp;&nbsp;</b>";
        releasedisplayed = releasedisplayed.replace("$" + element + "$", "");
        releasedisplayed += "$" + element + "$";
    } else {
        elements = document.getElementsByName(element);
        for (i = 0; i < elements.length; i++) {
            elements[i].style.display = 'none';
            try {
                fils = document.getElementsByName(elements[i].id);
                releasedisplayed = releasedisplayed.replace("$" + elements[i].id + "$", "");
                for (j = 0; j < fils.length; j++) {
                    document.getElementById("signe" + elements[i].id).innerHTML = "<b>+&nbsp;&nbsp;</b>";
                    fils[j].style.display = 'none';
                    try {
                        filsfils = document.getElementsByName(fils[j].id);
                        releasedisplayed = releasedisplayed.replace("$" + fils[j].id + "$", "");
                        for (k = 0; k < filsfils.length; k++) {
                            document.getElementById("signe" + fils[j].id).innerHTML = "<b>+&nbsp;&nbsp;</b>";
                            filsfils[k].style.display = 'none';
                        }
                    } catch(e) {}
                }
            } catch(e) {}
        }
        document.getElementById("signe" + element).innerHTML = "<b>+&nbsp;&nbsp;</b>";
        releasedisplayed = releasedisplayed.replace("$" + element + "$", "");
    }
	localStorage.setItem("alfyftreleasedisplayed", releasedisplayed);
}

