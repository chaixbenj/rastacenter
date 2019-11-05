ace.define("ace/snippets/gherkin",["require","exports","module"], function(require, exports, module) {
"use strict";

exports.snippetText = "########################################\n\
# Gherkin snippets - for Rails, see below #\n\
########################################\n\
\n\
snippet Feature\n\
	Feature:\n\
snippet Scenario\n\
	Scenario:\n\
snippet Scenario Outline\n\
	Scenario Outline:\n\
snippet Background\n\
	Background:\n\
snippet Given\n\
	Given\n\
snippet When\n\
	When\n\
snippet Then\n\
	Then\n\
snippet And\n\
	And\n\
snippet But\n\
	But\n\
snippet Examples:\n\
	Examples:\n\
";
exports.scope = "gherkin";

});                (function() {
                    ace.require(["ace/snippets/gherkin"], function(m) {
                        if (typeof module == "object" && typeof exports == "object" && module) {
                            module.exports = m;
                        }
                    });
                })();
            