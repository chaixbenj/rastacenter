    var th = undefined;
    var startOffset;
    function startresize(e, elem) {
      th = elem;
      startOffset = th.offsetWidth - e.pageX;
    }
    
    function redimcol(e) {
      if (th) {
        th.style.width = startOffset + e.pageX + 'px';
      }
    }
    
    function stopredimcol() {
      th = undefined;
    }

function setthpositionrelative() {
    thresizables = document.getElementsByName("thresizable");
    for (i=0;i<thresizables.length;i++) {
    thresizables[i].style.position = 'relative';
}
}


function setthpositionnone() {
    thresizables = document.getElementsByName("thresizable");
    for (i=0;i<thresizables.length;i++) {
    thresizables[i].style.position = null;
}


}





