function surligne_selected(elid, classname) {
    unsurligne(classname)
	if (classname == 'treecampain') {
		unsurligne('treecycle');
		unsurligne('treerelease')
	}
    if (document.getElementById(elid) != null) {
        elem = document.getElementById(elid);
        if (elem != null) {
            //elem.style.backgroundColor = "#b20c25";
			elem.style.border = "solid 5px";
			elem.style.borderColor = "#b20c25";
            topPos = elem.offsetTop;
            if (document.getElementById('left')) {document.getElementById('left').scrollTop = (topPos - document.getElementById('left').offsetTop);}
        }
    }
}

function unsurligne(classname) {
    allelems = document.getElementsByClassName(classname);
    for (i = 0; i < allelems.length; i++) {
        //allelems[i].style.backgroundColor = 'none';
		allelems[i].style.border = "solid 1px black";
    }
}