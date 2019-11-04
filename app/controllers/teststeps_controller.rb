class TeststepsController < ApplicationController
  before_action :require_login




def addnew
	test_id = params[:test_id].to_s
	lockTest(test_id)
	callingscreen = params[:callingscreen].to_s
	proc_id = params[:proc_id].to_s
	node_id = params[:node_id].to_s
	proc_param = params[:proc_param].to_s
	sheet_id = params[:sheetinit].to_s
	aftersequence = params[:afterstep].to_s.gsub("divstepseq","")
	procedure = Procedure.where(:id => proc_id).first
	test = Test.where(:id => test_id).first
	sheet = Sheet.where(:id => sheet_id).first
	new_step = nil
	if procedure != nil and test != nil and sheet != nil
		if test.sheet_id == nil
			test.sheet_id = sheet.id
			test.save
		end
		if aftersequence != ""
			sequence = aftersequence.to_i + 1
			TestStep.where("domaine_id =  #{@domaine} and test_id = #{test_id} and sequence >= #{sequence}").update_all("sequence = sequence + 1")
		else
			recordsequence = TestStep.select("max(sequence) as valeur").where(:domaine_id => @domaine, :test_id => test_id).first
			if recordsequence == nil or recordsequence.valeur == nil
			  sequence = 1
			else
			  sequence = recordsequence.valeur + 1
			end
		end
		new_step = TestStep.new
		new_step.domaine_id = @domaine
		new_step.test_id = test_id
		new_step.sequence = sequence
		new_step.sheet_id = sheet_id
		new_step.ext_node_id = node_id
		new_step.funcandscreen_id = procedure.funcandscreen_id
		new_step.procedure_id = proc_id
		new_step.parameters = proc_param[0..65535]
		new_step.save
		if test.has_real_step != 1
			test.has_real_step = 1
			test.save
		end
	end


	if new_step != nil
    if callingscreen == "testdesign"

	  rep = ""
		  rep += "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
		  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' class=\"linestep\" style=\"padding:5px 5px 5px 5px;\"><div >"
		  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{new_step.sequence});' id='#{new_step.sequence}' value='#{new_step.id}'/><span>&nbsp;#{procedure.name}</span>"

		  if procedure.return_values.to_s != ""
			returnvals = procedure.return_values.to_s.split("|$|")
			returnstring = ""
			for i in 0..returnvals.length-1
			  if i%2 == 0
				if i > 0 then returnstring += ", " + returnvals[i] else returnstring += returnvals[i] end
			  end
			end
			rep +=  "<span class=\"stepTextStyle\" style=\"color:white\">#{t('retour')} : #{returnstring}</span>"
		  end

		  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"

		  rep += "<button class=\"btncode\" title=\"#{t('code')}\"  style='float: right;'  onclick='window.open(\"../procedures/edit?nw=1&popup=true&procedure_id=#{procedure.id}\", \"code #{procedure.name}\", \"width=a,height=b\");'/>"

		  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{new_step.id})'></button>"
		  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{new_step.id})'></button>"

		  rep += "<button class='btnhold' id='btnhold#{new_step.id}' title=\"#{t('desactiver')}\" style='float: right;display: inline;' onclick='hold_step(#{new_step.id})'></button>"
		  rep += "<button class='btndonthold' id='btndonthold#{new_step.id}' title=\"#{t('reactiver')}\" style='float: right;display: none;' onclick='reactive_step(#{new_step.id})'></button>"

		  rep += "<button class='btncible' style='float: right;' onclick='cibleStep(#{new_step.sheet_id}, #{new_step.ext_node_id})'></button></div><div style=\"display: block\">"

		  parametres = procedure.parameters.to_s.split("|$|")
		  paramsvalues = new_step.parameters.to_s.split("|$|")
		  j = 0
		  for i in 0..parametres.length-1
			if i%2 == 0
			  rep += "<span class='stepTextStyle' style='color:#2a2b2a' onclick=\"modifparam('#{new_step.id}param#{j}', #{new_step.id}, #{j});\">#{parametres[i]}&nbsp;:&nbsp;</span>"
			  rep += "<input name='paramvalue#{new_step.id}' type='hidden' id='hidden#{new_step.id}param#{j}' value='#{paramsvalues[j].to_s.gsub("'","\'")}'/>"
			  rep += "<div style=\"display: inline\" onclick=\"modifparam('#{new_step.id}param#{j}', #{new_step.id}, #{j}, '');\" id='#{new_step.id}param#{j}' value='#{paramsvalues[j].to_s.gsub("'","\'")}'/>"
			  rep += "<span style=\"color:#016625\" class=\"stepTextStyle\">#{paramsvalues[j].to_s.gsub("'","\'")}&nbsp;</span></div>"

			  j += 1
			end
		  end

		  rep += "</div></div></div>"
    else
      rep = 'OK'
    end
		#render json: 'ok-#{new_step.id}-#{sequence}', status: :created
		ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
		render html: rep.html_safe
	else
		render html: 'KO'
	end

end


def addcode
	test_id = params[:test_id].to_s
	lockTest(test_id)
	callingscreen = params[:callingscreen].to_s
	code = params[:code].to_s
	test = Test.where(:id => test_id).first
	aftersequence = params[:afterstep].to_s.gsub("divstepseq","")
	if aftersequence != "" and TestStep.where(:domaine_id => @domaine, :test_id => test_id, :sequence => aftersequence).first != nil
		sequence = aftersequence.to_i + 1
		case code
			when "if"
				decalage = 3
			when "while"
				decalage = 2
			when "until"
				decalage = 2
			when "for"
				decalage = 2
			else
				decalage = 1
			end
		TestStep.where("domaine_id =  #{@domaine} and test_id = #{test_id} and sequence >= #{sequence}").update_all("sequence = sequence + #{decalage}")
	else
		recordsequence = TestStep.select("max(sequence) as valeur").where(:domaine_id => @domaine, :test_id => test_id).first
		if recordsequence == nil or recordsequence.valeur == nil
		  sequence = 1
		else
		  sequence = recordsequence.valeur + 1
		end
	end
	new_step = nil
	rep = ""
	if code == "given" or code == "when" or code == "then" or code == "and" or code == "but"
		gherkin_act = code
		code = "ATDD"
	end
	case code
		when "if"
			new_step = TestStep.new
			new_step.domaine_id = @domaine
			new_step.test_id = test_id
			new_step.sequence = sequence
			new_step.code = "if "
			new_step.type_code = "if"
			new_step.save
			elsestep = new_step.dup
			elsestep.sequence = sequence + 1
			elsestep.code = "else"
			elsestep.type_code = "else"
			elsestep.save
			endstep = new_step.dup
			endstep.sequence = sequence + 2
			endstep.code = "end"
			endstep.type_code = "end"
			endstep.save
			test.is_valid = 0
			test.save
			if new_step != nil
				if callingscreen == "testdesign"
				  rep = "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{new_step.sequence});' id='#{new_step.sequence}' value='#{new_step.id}'/>"
				  rep += "<input type='hidden' id='hiddeninitcode#{new_step.id}' value='#{new_step.code.gsub("'","\'")}'/>"
				  rep += "<span class='stepTextStyle' onclick=\"modifcode(this, #{new_step.id}, 'in', true);\">&nbsp;&nbsp;#{new_step.code}</span>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{new_step.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{new_step.id})'></button>"
				  rep += "</div></div></div>"

				  rep += "<div name=\"divstep\" id='divstepseq#{elsestep.sequence}' title='#{elsestep.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{elsestep.id}\" step_type='#{elsestep.type_code}' class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{elsestep.sequence});' id='#{elsestep.sequence}' value='#{elsestep.id}'></input>"
				  rep += "<span class='stepTextStyle'>&nbsp;&nbsp;#{elsestep.code}</span>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{elsestep.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{elsestep.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{elsestep.id})'></button>"
				  rep += "</div></div></div>"

				  rep += "<div name=\"divstep\" id='divstepseq#{endstep.sequence}' title='#{endstep.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{endstep.id}\" step_type='#{endstep.type_code}' class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{endstep.sequence});' id='#{endstep.sequence}' value='#{endstep.id}'></input>"
				  rep += "<span class='stepTextStyle'>&nbsp;&nbsp;#{endstep.code}</span>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{endstep.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{endstep.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{endstep.id})'></button>"
				  rep += "</div></div><!--validcode--></div>"
				end
			end

		when "for"
			new_step = TestStep.new
			new_step.domaine_id = @domaine
			new_step.test_id = test_id
			new_step.sequence = sequence
			new_step.code = "for "
			new_step.type_code = "for"
			new_step.save
			endstep = new_step.dup
			endstep.sequence = sequence + 1
			endstep.code = "end"
			endstep.type_code = "end"
			endstep.save
			test.is_valid = 0
			test.save
			if new_step != nil
				if callingscreen == "testdesign"
				  rep = "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{new_step.sequence});' id='#{new_step.sequence}' value='#{new_step.id}'/>"
				  rep += "<input type='hidden' id='hiddeninitcode#{new_step.id}' value='#{new_step.code.gsub("'","\'")}'/>"
				  rep += "<span class='stepTextStyle' onclick=\"modifcode(this, #{new_step.id}, 'in', true);\">&nbsp;&nbsp;#{new_step.code}</span>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{new_step.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{new_step.id})'></button>"
				  rep += "</div></div></div>"

				  rep += "<div name=\"divstep\" id='divstepseq#{endstep.sequence}' title='#{endstep.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{endstep.id}\" step_type='#{endstep.type_code}' class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{endstep.sequence});' id='#{endstep.sequence}' value='#{endstep.id}'></input>"
				  rep += "<span class='stepTextStyle'>&nbsp;&nbsp;#{endstep.code}</span>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{endstep.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{endstep.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{endstep.id})'></button>"
				  rep += "</div></div><!--validcode--></div>"
				end
			end

		when "while"
			new_step = TestStep.new
			new_step.domaine_id = @domaine
			new_step.test_id = test_id
			new_step.sequence = sequence
			new_step.code = "begin"
			new_step.type_code = "begin"
			new_step.save
			endstep = new_step.dup
			endstep.sequence = sequence + 1
			endstep.code = "end while "
			endstep.type_code = "end while"
			endstep.save
			test.is_valid = 0
			test.save
			if new_step != nil
				if callingscreen == "testdesign"
				  rep = "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{new_step.sequence});' id='#{new_step.sequence}' value='#{new_step.id}'/>"
				  rep += "<span class='stepTextStyle'>&nbsp;&nbsp;#{new_step.code}</span>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{new_step.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{new_step.id})'></button>"
				  rep += "</div></div></div>"

				  rep += "<div name=\"divstep\" id='divstepseq#{endstep.sequence}' title='#{endstep.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{endstep.id}\" step_type='#{endstep.type_code}' class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{endstep.sequence});' id='#{endstep.sequence}' value='#{endstep.id}'></input>"
				  rep += "<input type='hidden' id='hiddeninitcode#{endstep.id}' value='#{endstep.code.gsub("'","\'")}'/>"
				  rep += "<span class='stepTextStyle' onclick=\"modifcode(this, #{endstep.id}, 'in', true);\">&nbsp;&nbsp;#{endstep.code}</span>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{endstep.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{endstep.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{endstep.id})'></button>"
				  rep += "</div></div><!--validcode--></div>"
				end
			end

		when "until"
			new_step = TestStep.new
			new_step.domaine_id = @domaine
			new_step.test_id = test_id
			new_step.sequence = sequence
			new_step.code = "begin"
			new_step.type_code = "begin"
			new_step.save
			endstep = new_step.dup
			endstep.sequence = sequence + 1
			endstep.code = "end until "
			endstep.type_code = "end until"
			endstep.save
			test.is_valid = 0
			test.save
			if new_step != nil
				if callingscreen == "testdesign"
				  rep = "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{new_step.sequence});' id='#{new_step.sequence}' value='#{new_step.id}'/>"
				  rep += "<span class='stepTextStyle'>&nbsp;&nbsp;#{new_step.code}</span>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{new_step.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{new_step.id})'></button>"
				  rep += "</div></div></div>"

				  rep += "<div name=\"divstep\" id='divstepseq#{endstep.sequence}' title='#{endstep.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{endstep.id}\" step_type='#{endstep.type_code}' class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{endstep.sequence});' id='#{endstep.sequence}' value='#{endstep.id}'></input>"
				  rep += "<input type='hidden' id='hiddeninitcode#{endstep.id}' value='#{endstep.code.gsub("'","\'")}'/>"
				  rep += "<span class='stepTextStyle' onclick=\"modifcode(this, #{endstep.id}, 'in', true);\">&nbsp;&nbsp;#{endstep.code}</span>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{endstep.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{endstep.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{endstep.id})'></button>"
				  rep += "</div></div><!--validcode--></div>"
				end
			end

		when "code"
			new_step = TestStep.new
			new_step.domaine_id = @domaine
			new_step.test_id = test_id
			new_step.sequence = sequence
			new_step.code = "#{t('type_your_ruby_code_line')}"
			new_step.type_code = "code"
			new_step.save
			if new_step != nil
				if callingscreen == "testdesign"
				  rep = "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' name=\"linecondition\" class=\"linecondition\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{new_step.sequence});' id='#{new_step.sequence}' value='#{new_step.id}'/>"
				  rep += "<span class='stepTextStyle' onclick=\"modifcode(this, #{new_step.id} , 'in', true);\">&nbsp;&nbsp;#{new_step.code}</span>"
				  rep += "<input type='hidden' id='hiddeninitcode#{new_step.id}' value='#{new_step.code.gsub("'","\'")}'/>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{new_step.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{new_step.id})'></button>"
				  rep += "</div></div><!--validcode--></div>"

				end
			end

		when "comment"
			new_step = TestStep.new
			new_step.domaine_id = @domaine
			new_step.test_id = test_id
			new_step.sequence = sequence
			new_step.code = "#{t('commentaire')}"
			new_step.type_code = "comment"
			new_step.save
			if new_step != nil
				if callingscreen == "testdesign"
				  rep = "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' name=\"linecomment\" class=\"linecomment\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{new_step.sequence});' id='#{new_step.sequence}' value='#{new_step.id}'/>"
				  rep += "<span name=\"foldunflod\" onclick=\"filtrestepundercomment(this, null);\" style=\"color:black\"><b>-</b></span>"
				  rep += "<span class='stepTextStyle' onclick=\"modifcode(this, #{new_step.id} , 'in', false);\">&nbsp;&nbsp;#{new_step.code}</span>"
				  rep += "<input type='hidden' id='hiddeninitcode#{new_step.id}' value='#{new_step.code.gsub("'","\'")}'/>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{new_step.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{new_step.id})'></button>"
				  rep += "</div></div></div>"

				end
			end

		when "commentodo"
			new_step = TestStep.new
			new_step.domaine_id = @domaine
			new_step.test_id = test_id
			new_step.sequence = sequence
			new_step.code = "#{t('commentaire')} #{t('a_faire')}"
			new_step.type_code = "commentodo"
			new_step.save
			if new_step != nil
				if callingscreen == "testdesign"
				  rep = "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' name=\"linecomment\" class=\"linecommenttodo\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{new_step.sequence});' id='#{new_step.sequence}' value='#{new_step.id}'/>"
				  rep += "<span name=\"foldunflod\" onclick=\"filtrestepundercomment(this, null);\" style=\"color:black\"><b>-</b></span>"
				  rep += "<span class='stepTextStyle' onclick=\"modifcode(this, #{new_step.id} , 'in', false);\">&nbsp;&nbsp;#{new_step.code}</span>"
				  rep += "<input type='hidden' id='hiddeninitcode#{new_step.id}' value='#{new_step.code.gsub("'","\'")}'/>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{new_step.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{new_step.id})'></button>"
				  rep += "<button class='btnvalid' id='btnvalid#{new_step.id}' title=\"#{t('fait')}\" style='float: right;' onclick='commenttododone(#{new_step.id})'></button>"
				  rep += "</div></div></div>"

				end
			end

		when "ATDD"
			new_step = TestStep.new
			new_step.domaine_id = @domaine
			new_step.test_id = test_id
			new_step.sequence = sequence
			atddstep = Test.where(:id => params[:idatddstep]).first
			new_step.save
			htlmatdd = atdd_step_param(atddstep.description, atddstep.parameters, new_step.id)
			new_step.code = "##{params[:idatddstep]}|$|#{atddstep.description.gsub("\n", " ")}|$|"
			new_step.atdd_test_id = atddstep.id
			new_step.type_code = "ATDD#{gherkin_act}"
			new_step.save
			if test.has_real_step != 1
				test.has_real_step = 1
				test.save
			end
			if new_step != nil
				if callingscreen == "testdesign"
				  rep = "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' name=\"linecomment\" class=\"linegherkin\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<input type='checkbox' name='chbxinput' onmousedown='checkShift(event, #{new_step.sequence});' id='#{new_step.sequence}' value='#{new_step.id}'/>"
				  rep += "<span class='stepTextStyle' >&nbsp;<b>#{gherkin_act}</b>&nbsp;#{htlmatdd}</span>"
				  #rep += "<input type='hidden' id='hiddeninitcode#{new_step.id}' value='#{atddstep.description.gsub("'","\'")}'/>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"
				  rep += "<button class='btnpasteafter' name='btnpasteafter' title=\"#{t('coller_apres')}\" style='float: right;display: none;' onclick='pastestep(\"after\", #{new_step.id})'></button>"
				  rep += "<button class='btnpastebefore' name='btnpastebefore' title=\"#{t('coller_avant')}\" style='float: right;display: none;' onclick='pastestep(\"before\", #{new_step.id})'></button>"
				  rep += "<button class=\"btncode\" title=\"#{t('code')}\"  style='float: right;'  onclick='var a = 0.8 * document.body.offsetWidth;var b = 0.8 * document.body.offsetHeight;window.open(\"../tests/edit?nw=1&popup=true&write=1&load=1&test_id=#{new_step.atdd_test_id}&atddsteps=1\", \"code\", \"directories=0,titlebar=0,toolbar=0,menubar=0,width=1000,height=800\");'/>"
				  rep += "<button class='btnhold' id='btnhold#{new_step.id}' title=\"#{t('desactiver')}\" style='float: right;display: inline;' onclick='hold_step(#{new_step.id})'></button>"
				  rep += "<button class='btndonthold' id='btndonthold#{new_step.id}' title=\"#{t('reactiver')}\" style='float: right;display: none;' onclick='reactive_step(#{new_step.id})'></button>"
				  rep += "</div></div></div>"

				end
			end

		when "datatable"
			new_step = TestStep.new
			new_step.domaine_id = @domaine
			new_step.test_id = test_id
			new_step.sequence = sequence
			new_step.code = "Examples:\n|header|\n|value|"
			new_step.type_code = "TmpATDDAr"
			new_step.temporary = 1
			new_step.save
			if new_step != nil
				if callingscreen == "testdesign"
				  rep = "<div name=\"divstep\" id='divstepseq#{new_step.sequence}' title='#{new_step.sequence}' onclick='selectTestStep(this);' draggable=\"true\" ondragstart=\"dragStarted(event, this.id)\" ondragover=\"draggingOver(event, this.id)\" ondrop=\"dropped(event, this.id)\">"
				  rep += "<div id=\"divstepid#{new_step.id}\" step_type='#{new_step.type_code}' class=\"linestephold\" style=\"padding:5px 5px 5px 5px;\"><div >"
				  rep += "<span class='stepTextStyle' tempo='true' onclick=\"modifcode(this, #{new_step.id} , 'in', false);\">&nbsp;&nbsp;#{new_step.code.gsub("\n","<br>").html_safe}</span>"
				  rep += "<input type='hidden' id='hiddeninitcode#{new_step.id}' value='#{new_step.code.gsub("'","\'")}'/>"
				  rep += "<button class='btndel' style='float: right;' onclick='deleteStep(#{new_step.id})'></button>"
				  rep += "<button class='btnvalid' id='btnvalid#{new_step.id}' title=\"#{t('fait')}\" style='float: right;' onclick='validArrayAtdd(#{new_step.id})'></button>"
				  rep += "</div></div></div>"

				end
			end

		else
		end
	ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
	render html: rep.html_safe


end


def reorder
  test_id = params[:test_id].to_s
  test = Test.where(:id => test_id).first
  lockTest(test_id)
  istart = params[:istart].to_s.to_i
  idest = params[:idest].to_s.to_i
  stepstart = TestStep.where(:domaine_id => @domaine, :test_id => test_id, :sequence => istart).first
  if stepstart.temporary != nil and stepstart.type_code != nil and stepstart.type_code != "comment" and stepstart.type_code != "commentodo" and stepstart.type_code[0..3] != "ATDD" and stepstart.type_code[0..3] != "TmpA"
	test.is_valid = 0
	test.save
  end
  if istart < idest
    TestStep.where("domaine_id =  #{@domaine} and test_id = #{test_id} and sequence <= #{idest} and sequence > #{istart}").update_all("sequence = sequence - 1")
    if stepstart != nil
      stepstart.sequence = idest
      stepstart.save
    end
  end

  if istart > idest
    TestStep.where("domaine_id =  #{@domaine} and test_id = #{test_id} and sequence >= #{idest} and sequence < #{istart}").update_all("sequence = sequence + 1")
    if stepstart != nil
      stepstart.sequence = idest
      stepstart.save
    end
  end

  if istart == 1 or idest == 1
    if test != nil
      step = TestStep.where(:domaine_id => @domaine, :test_id => test_id, :sequence => 1).first
      if step != nil and test.sheet_id != step.sheet_id
        test.sheet_id = step.sheet_id
        test.save
      end
    end
  end

  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
  render html: "reorder;#{istart};#{idest};#{stepstart.type_code}"

end



def delete
  lockTest(params[:test_id])
	step_id = params[:step_id]
  step = TestStep.where(:id => step_id).first
  if step != nil
  	test = Test.where(:id => params[:test_id]).first
  	if step.temporary != nil and step.type_code != nil and step.type_code != "comment" and step.type_code != "commentodo" and step.type_code != "else"  and step.type_code[0..3] != "ATDD" and step.type_code[0..3] != "TmpA"
  		test.is_valid = 0
  		test.save
  	end
  	depstring = ""
  	TestStep.where("domaine_id =  #{@domaine} and test_id = #{step.test_id} and sequence > #{step.sequence}").update_all("sequence = sequence - 1")
  	step.destroy
    if test.has_real_step == 0 then updateTestRealSteps(test.id) end
  end

  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)

  render html: "delete;#{step.type_code};#{step_id}#{depstring}"
end


def hold
  lockTest(params[:test_id])
  step_id = params[:step_id]
  test = Test.where(:id => params[:test_id]).first
  step = TestStep.where(:id => step_id).first
  if step != nil
	step.hold = 1
	step.save
  end
  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
  render html: "hold;#{step_id}"
end

def unhold
  lockTest(params[:test_id])
  step_id = params[:step_id]
  test = Test.where(:id => params[:test_id]).first
  step = TestStep.where(:id => step_id).first
  if step != nil
	step.hold = nil
	step.save
  end
  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
  render html: "unhold;#{step_id}"
end

def changeparamvalue
  lockTest(params[:test_id])
  step_id = params[:step_id]
  step = TestStep.where(:id => step_id).first
  if step != nil
	if step.type_code != nil then
		step.code = params[:parameters][0..65535]
	else
		step.parameters = params[:parameters][0..65535]
	end
    step.save
  end
  test = Test.where(:id => params[:test_id]).first
  if step.temporary == nil and step.type_code != nil and step.type_code != "comment" and step.type_code != "commentodo" and step.type_code != "else" and step.type_code[0..3] != "ATDD"
	test.is_valid = 0
	test.save
  end
  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
  render html: "changeparam;#{step_id};#{params[:parameters]}"
end

def tododone
  lockTest(params[:test_id])
  step_id = params[:step_id]
  step = TestStep.where(:id => step_id).first
  if step != nil
	step.type_code = "comment"
    step.save
	mytest = Test.where(:id => params[:test_id]).first
	ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{mytest.id}", :version_id => mytest.version_id, :get => 0).update_all(:get => 1)
  end
  render html: "done;#{step_id};"
end

def paste
  @popup   = params[:popup].to_s
  lockTest(params[:test_id])
  afterbefore = params[:paste_after_before].to_s
  elem_dest = params[:paste_element_dest].to_s
  step_to_paste = params[:step_to_paste].to_s.split('||')
  copycut = step_to_paste[0].gsub('|', '')
  step_to_paste = params[:step_to_paste].gsub('copy|','').gsub('cut|','').to_s.split('||')
  mytest = Test.where(:id => params[:test_id]).first

  code_to_valid = "ifendforbeginend until end whilecode"
  if mytest != nil
      ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{mytest.id}", :version_id => mytest.version_id, :get => 0).update_all(:get => 1)
      nbsteptopaste = step_to_paste.length
      if elem_dest == ""
        istart = 1
      else
        destinationsequence = TestStep.where(:id => elem_dest).first.sequence
        istart = destinationsequence
        if afterbefore == 'after' #on fait la place dans la destination
          TestStep.where("domaine_id =  #{@domaine} and test_id = #{mytest.id} and sequence > #{destinationsequence}").update_all("sequence = sequence + #{nbsteptopaste}")
          istart += 1
        else
          TestStep.where("domaine_id =  #{@domaine} and test_id = #{mytest.id} and sequence >= #{destinationsequence}").update_all("sequence = sequence + #{nbsteptopaste}")
        end
      end
	  is_code_step = false
      if copycut == 'copy' #on copie
        step_to_paste.each do |step_id|
          step_id = step_id.gsub('|', '')
          initteststep = TestStep.where(:id => step_id).first
          newstep = initteststep.dup
          newstep.test_id = mytest.id
          newstep.sequence = istart
          newstep.user_maj = nil
          newstep.save
		  if is_code_step == false and newstep.temporary != nil and newstep.type_code != nil and (code_to_valid.index(newstep.type_code) != nil) then is_code_step = true end
          istart += 1
		  if mytest.has_real_step != 1 and (newstep.procedure_id != nil or newstep.atdd_test_id != nil)
			mytest.has_real_step = 1
			mytest.save
		  end
        end
		if is_code_step
			mytest.is_valid = 0
			mytest.save
		end
      else
        if copycut == 'cut' #ou on colle
          oldtest_id = nil
		  oldtest = nil
		  real_step = false
            step_to_paste.each do |step_id|
              step_id = step_id.gsub('|', '')
              if oldtest_id == nil
                oldtest = TestStep.where(:id => step_id).first
                if oldtest != nil
                  oldtest_id = oldtest.test_id
				  oldtest = Test.where(:id => oldtest_id).first
                end
              end
              TestStep.where(:id => step_id).update(:test_id => mytest.id, :sequence => istart)
			  if real_step == false or is_code_step == false
				step = TestStep.where(:id => step_id).first
				if real_step == false then real_step = step.procedure_id != nil || step.atdd_test_id != nil end
				if is_code_step == false and step.temporary != nil and step.type_code != nil and (code_to_valid.index(step.type_code) != nil) then is_code_step = true end
			  end
              istart += 1
          end
          recalculsequence(oldtest_id)
		  if mytest.has_real_step != 1 and real_step
			mytest.has_real_step = 1
			mytest.save
		  end
		  if TestStep.select("1").where("domaine_id = #{@domaine} and test_id=#{oldtest.id} and (procedure_id is not null or atdd_test_id is not null)").first == nil
			oldtest.has_real_step = 0
			oldtest.save
		  end
		  if is_code_step
			mytest.is_valid = 0
			mytest.save
			oldtest.is_valid = 0
			oldtest.save
		  end
        end
      end
    end
	params[:write] = params[:write]
	flash[:test_id] = params[:test_id]
	flash[:sheet_id] = params[:sheet_id]
	flash[:popup] = @popup
  redirect_to controller: 'tests', action: 'edit'
end


def validarrayatdd
	stepid = params[:arraystep].to_s
	if stepid != ""
		step = TestStep.where(:id => stepid).first
		if step != nil
			step.temporary = nil
			step.type_code = "ATDDarray"
			step.save
			test = Test.where(:id => step.test_id).first
      if test.has_real_step == 0 then updateTestRealSteps(test.id) end 
			ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
		end
	end
	params.each do |param|
      flash["#{param.to_s}"] = params["#{param.to_s}"]
    end
	redirect_to controller: 'tests', action: 'edit'
end

def lockTest(test_id)
  Lockobject.where("domaine_id = #{@domaine} and obj_id = #{test_id} and obj_type = 'test'").delete_all
  newlock = Lockobject.new
  newlock.domaine_id = @domaine
  newlock.obj_id = test_id
  newlock.obj_type = 'test'
  newlock.user_id = @my_user_id
  newlock.save
  cookies[:objectlocked] = '1'
end


def recalculsequence(test_id)
  if test_id != nil
    teststeps = TestStep.where(:domaine => @domaine, :test_id => test_id).order(:sequence).all
    i = 0
    teststeps.each do |teststep|
      i+=1
      teststep.sequence = i
      teststep.save
    end
  end
end



def validatestructure
	test_id = params[:test_id].to_s
	lockTest(test_id)
	test_code = ""
	message = ""
	if test_id != nil
		test = Test.where(:id => test_id).first
		teststeps = TestStep.where(:domaine => @domaine, :test_id => test_id, :temporary => nil).order(:sequence).all
		teststeps.each do |teststep|
			if teststep.procedure_id != nil
				test_code += "\n" #"$procedure.proc_#{teststep.procedure_id}\n"
			else
				if teststep.type_code == "comment" or teststep.type_code == "commentodo"
					test_code += "\n" #"# #{teststep.code}\n"
				else
					if teststep.type_code.to_s[0..3] != "ATDD" then test_code += "#{teststep.code}\n" end
				end
			end
		end
		if test_code.has_valid_syntax
			if test != nil then test.is_valid = 1 end
			test.save
			message = t('ecr_test.structure_valide')
			rep = "<span class='succesMessage' onclick='this.parentNode.removeChild(this)'>#{message}&nbsp;<b>x</b></span>"
		else
			if test != nil then test.is_valid = 0 end
			test.save
			message = test_code.syntax_errors
			rep = "<span class='errorMessage' onclick='this.parentNode.removeChild(this)'>#{message}&nbsp;<b>x</b></span>"
		end
		ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
	end
	render html: rep.html_safe
end

def atdd_step_param(desc, parameters, idstep)
  arguments = desc.scan(/arg(\d+)/)
  if arguments!=nil && arguments.length>0
      for i in 0..arguments.length-1
        pname = "arg#{arguments[i][0]}"
        desc = desc.gsub("#{pname}", "<input type='text' style='font-size:11px' id='p#{idstep}#{pname}' name='#{pname}' size=10 placeholder='#{pname}' value='' onclick='field = this;' onblur='majatddstepparamvalue(this, #{idstep})'></input>")
      end
  end
	return desc
end

def changeparamatddvalue()
	stepid = params[:stepid].to_s
	pname = params[:pname].to_s
	pvalue = params[:pvalue].to_s
	step = TestStep.where(:id => stepid).first
	if step != nil
    test = Test.where(:id => step.test_id).first
    arguments = step.code.to_s.scan(/arg(\d+)/)
    actualstepparameters = step.parameters.to_s.split("|$|")
    stepparameters = ""
    if arguments!=nil && arguments.length>0
        for i in 0..arguments.length-1
            if  "arg#{arguments[i][0]}" == pname then
              stepparameters += "#{pvalue}|$|"
            else
              if actualstepparameters.length>i then stepparameters += "#{actualstepparameters[i]}|$|" else stepparameters += "|$|" end
            end
        end
    end
    step.parameters = stepparameters
		step.save
		ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{step.test_id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
	end
	render html: "ok"
end


def updateTestRealSteps(test_id)
  temporaryStep = TestStep.where(:domaine_id => @domaine, :test_id => test_id, :temporary => 1).first
  if temporaryStep == nil then Test.where(:id => test_id).update_all(:has_real_step => 1) end
end
end
