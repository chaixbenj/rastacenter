function formatslash(el) 
{
    var s = el.value;
    var i = "\\".split('');
    var o = "/".split('');
    var map = {};
    i.forEach(function(el, idx) {map[el] = o[idx];});
    var news = s.replace(/[^A-Za-z0-9]/g, function(ch) { return map[ch] || ch; }).replace(/ /g,' ');
    el.value = news;
}

function formatasvariable(el) 
{
    var s = el.value;
    var i = "àâäçèéêëîïôùûüñ -*/\\+£$%!:;,?.§µ¨^=(){}[]|&~#'@°\"".split('');
    var o = "aaaceeeeiiouuun\_____                            ".split('');
    var map = {};
    i.forEach(function(el, idx) {map[el] = o[idx];});
    var news = '$' + s.replace(/[^A-Za-z0-9]/g, function(ch) { return map[ch] || ch; }).replace(/ /g,'');
    el.value = news;
}


function formatasaction(el) 
{
    var s = el.value;
    var i = "àâäçèéêëîïôùûüñ\_-*/\\+£$%!:;,?.§µ¨^=(){}[]|&~#'@°\"".split('');
    var o = "aaaceeeeiiouuun                                  ".split('');
    var map = {};
    i.forEach(function(el, idx) {map[el] = o[idx];});
    var news = '_' + s.replace(/[^A-Za-z0-9]/g, function(ch) { return map[ch] || ch; }).replace(/ /g,'');
    el.value = news;
}


function formatasparam(el) 
{
    var s = el.value;
    var i = "àâäçèéêëîïôùûüñ><\_-*/\\+£$%!:;,?.§µ¨^=(){}[]|&~#'@°\"".split('');
    var o = "aaaceeeeiiouuun                                    ".split('');
    var map = {};
    i.forEach(function(el, idx) {map[el] = o[idx];});
    var news = s.replace(/[^A-Za-z0-9]/g, function(ch) { return map[ch] || ch; }).replace(/ /g,'');
	if (news.length > 0) {news = news[0].toLowerCase() + news.substring(1);}
    el.value = news; 
}

function formatasprocedure(el) 
{
    var s = el.value;
    var i = "àâäçèéêëîïôùûüñ -*/\\+£$%!:;,?.§µ¨^=(){}[]|&~#'@°\"".split('');
    var o = "aaaceeeeiiouuun\_____                            ".split('');
    var map = {};
    i.forEach(function(el, idx) {map[el] = o[idx];});
    var news = s.replace(/[^A-Za-z0-9]/g, function(ch) { return map[ch] || ch; }).replace(/ /g,'');
    el.value = news;
}


function formatascode(el) 
{
    var s = el.value;
    var i = "àâäçèéêëîïôùûüñ -*/\\+£$%!:;,?.§µ¨^=(){}[]|&~#'@°\"".split('');
    var o = "aaaceeeeiiouuun\_____                            ".split('');
    var map = {};
    i.forEach(function(el, idx) {map[el] = o[idx];});
    var news = s.replace(/[^A-Za-z0-9]/g, function(ch) { return map[ch] || ch; }).replace(/ /g,'');
    el.value = news;
}
