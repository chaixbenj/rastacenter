class WsController < ApplicationController
  skip_before_action :require_login
  skip_before_action :verify_authenticity_token


  def isdeclaredcomputer
	  computer = Computer.where(:hostrequest => params[:hostrequest], :guid => params[:guid]).first
    if computer == nil
      render json: 'false', status: '200'
    else
      computer.last_connexion = Time.now
      computer.save
      render json: 'true', status: '200'
    end
  end

  def declarecomputer
    domaine = Domaine.where(:guid => params[:domain]).first
    if domaine != nil
      user, pwd = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
      _encryptedpassword = Commun.get_encrypted_password(pwd)
      user = User.where(:domaine_id => domaine.id, :login => user, :pwd => _encryptedpassword[0..49]).first
      if user != nil
        domaine = Domaine.where(:id => user.domaine_id).first
          hostrequest = params[:name]
          computer = Computer.where(:domaine_id => domaine.id, :hostrequest => hostrequest).first
          if computer == nil
            computer = Computer.new
            computer.hostrequest = hostrequest
            computer.guid = (SecureRandom.uuid).to_s
            computer.domaine_id = domaine.id
            computer.last_connexion = Time.now
            computer.save
            data = "{\"hostrequest\":\"#{computer.hostrequest}\" , \"guid\":\"#{computer.guid}\"}"
            render json: data, status: '200'
          else
            render json: '{"status":"200", "error":"computer name already exist"}', status: '200'
          end
      else
        render json: '{"status":"401", "error":"authentication error on domain"}', status: '401'
      end
    else
      render json: '{"status":"200", "error":"bad domain"}', status: '200'
    end
  end

  def undeclarecomputer
	  Computer.where(:guid => params[:guid]).delete_all
    render json: 'true', status: '200'
  end

  def gettokenforrun
	  computer = Computer.where(:guid => params[:guid]).first
    if computer != nil
      hostrequest = computer.hostrequest
      test_name = ""
      computer.last_connexion = Time.now
      computer.save
      run = Run.where(:domaine_id => computer.domaine_id, :status => 'startable', :hostrequest => hostrequest).first
	  nbrun = Run.select("count(1) as nb").where("domaine_id = #{computer.domaine_id} and hostrequest = \"#{hostrequest}\" and status in ('startable', 'blocked')").first
      if run != nil
        run.status = 'started'
		run.created_at = Time.now.localtime
        run.save
        if run.test_id != nil
          test = Test.where(:id => run.test_id).first
          if test != nil
            test_name = test.name
          end
        end
        runauthen = RunAuthentication.where(:domaine_id => computer.domaine_id, :run_id => run.id).first
        if runauthen == nil
          runauthen = RunAuthentication.new
          runauthen.run_id = run.id
          runauthen.user_id = run.user_id
          runauthen.domaine_id = run.domaine_id
          runauthen.uuid = (SecureRandom.uuid).to_s
          runauthen.save
        end
        required_gem = RequiredGem.where(:domaine_id => computer.domaine_id, :version_id => run.version_id).first
        if required_gem != nil
          gems = required_gem.gems
        else
          gems = ""
        end

        last_get_action = ComputerLastGet.where(:domaine_id => computer.domaine_id, :hostrequest => hostrequest, :object_type => "action",  :version_id => run.version_id, :get => 0).first
        if last_get_action == nil then get_action = 1 else get_action = 0 end

		funcandscreens = Funcandscreen.select("distinct funcandscreens.id as func_id, computer_last_gets.get as getscr")
			.joins("INNER JOIN procedures on procedures.domaine_id=funcandscreens.domaine_id and procedures.version_id = #{run.version_id} and procedures.funcandscreen_id = funcandscreens.id")
			.joins("LEFT OUTER JOIN computer_last_gets on computer_last_gets.domaine_id=funcandscreens.domaine_id and computer_last_gets.hostrequest = \"#{hostrequest}\" and computer_last_gets.object_type = concat('FuncAndScreen', funcandscreens.id) and computer_last_gets.version_id = #{run.version_id} and computer_last_gets.get = 0")
			.where("funcandscreens.domaine_id=#{computer.domaine_id}").all
		funcok = []
		funcko = []
		funcandscreens.each do |funcandscreen|
			if funcandscreen.getscr == nil then funcko << funcandscreen.func_id else funcok << funcandscreen.func_id end
		end

		tests = Test.select("distinct tests.id as test_id, computer_last_gets.get as getscr")
			.joins("LEFT OUTER JOIN computer_last_gets on computer_last_gets.domaine_id=tests.domaine_id and computer_last_gets.hostrequest = \"#{hostrequest}\" and computer_last_gets.object_type = concat('Test', tests.id) and computer_last_gets.version_id = #{run.version_id} and computer_last_gets.get = 0")
			.where("tests.domaine_id=#{computer.domaine_id} and tests.version_id = #{run.version_id} and tests.is_valid = 1").all
		testok = []
		testko = []
		tests.each do |test|
			if test.getscr == nil then testko << test.test_id else testok << test.test_id end
		end

        data = "{\"run\":\"#{runauthen.run_id.to_s}\" , \"nbrun\":\"#{nbrun.nb.to_s}\" , \"hostrequest\":\"#{hostrequest}\" , \"uuid\":\"#{runauthen.uuid.to_s}\", \"type\":\"#{run.run_type}\", \"run_father_id\":\"#{run.run_father_id}\", \"start_node_id\":\"#{run.start_node_id}\", \"test_id\":\"#{run.test_id}\", \"test_name\":\"#{test_name}\", \"suite_id\":\"#{run.suite_id}\",\"campain_id\":\"#{run.campain_id}\",\"version_id\":\"#{run.version_id}\",\"get_action\":#{get_action} ,\"funcko\":#{funcko} ,\"funcok\":#{funcok} ,\"testko\":#{testko} ,\"testok\":#{testok} ,\"required_gems\":\"#{gems.gsub("\n","||").gsub("\"","'")}\"}"
      else
        data = "{\"run\":\"norun\" , \"uuid\":\"norun\" , \"nbrun\":\"#{nbrun.nb.to_s}\"}"
      end
      render json: data.force_encoding("UTF-8"), status: '200'
    else
      render json: '404', status: '404'
    end
  end

  def getrunconfigs
    hostrequest = params[:hostrequest]
    version_id = params[:version_id]
    computer = Computer.where(:hostrequest => hostrequest, :guid => params[:guid]).first
    if computer != nil
      run = Run.where(:id => params[:run_id]).first
      render json: run.conf_string.to_s.force_encoding("UTF-8"), status: '200'
    else
      render json: '404', status: '404'
    end
  end

  def getfuncandscreens
	version_id = params[:version_id]
    hostrequest = params[:hostrequest]
    computer = Computer.where(:hostrequest => hostrequest, :guid => params[:guid]).first
    if computer != nil
      @domaine = computer.domaine_id
      data = []
	  params[:funcids].split(",").each do |funcid|
		funcandscreen = Funcandscreen.select("id, name").where(:id => funcid).first
		func_class = "require_relative './Actions.rb'\n"
		func_class += "require_relative '../bin/DomElement.rb'\n"
		func_class += "class FuncAndScreen#{funcandscreen.id}\n"
		func_class += "##{funcandscreen.name.gsub("\n", "").gsub("\r","")}\n"
		dominitialize = getFuncAndScreenDomElement(funcandscreen.id, version_id)
		func_class += "def initialize\n"
		func_class += "	@action = Actions.new\n"
		func_class += dominitialize
		func_class += "end\n"
		func_class += getFuncAndScreenProcs(funcandscreen.id, version_id) + "\n"
		func_class += "end"
		data << JSON.generate({:name => "FuncAndScreen#{funcandscreen.id}", :code => func_class.force_encoding("UTF-8")})
		saveLastGet("FuncAndScreen#{funcandscreen.id}", version_id, hostrequest)
	  end
      render json: data, status: '200'
    else
      render json: '404', status: '404'
    end
  end

  def saveLastGet(obj_type, version_id, hostrequest)
	  getLast = ComputerLastGet.where(:domaine_id => @domaine, :hostrequest => hostrequest, :version_id => version_id, :object_type => obj_type).first
      if getLast != nil
        getLast.get = 0
        getLast.save
      else
        getLast = ComputerLastGet.new
        getLast.domaine_id = @domaine
        getLast.hostrequest = hostrequest
        getLast.version_id = version_id
        getLast.object_type = obj_type
        getLast.get = 0
        getLast.save
      end
  end

  def getFuncAndScreenDomElement(func_id, version_id)
	domelements = Domelement.where("domaine_id=#{@domaine} and version_id = #{version_id} and funcandscreen_id = #{func_id}").all
	dominitialize = ""
	domelements.each do |domelement|
       dominitialize += "	@domelement#{domelement.current_id}_ = DomElement.new(#{domelement.strategie}, \"#{domelement.path.gsub("\"","\\\"")}\", \"#{domelement.name.gsub("\"","\\\"")}\", \"#{domelement.description.gsub("\"","\\\"").gsub("\n"," ")}\")\n"
    end
	return dominitialize
  end

  def getFuncAndScreenProcs(func_id, version_id)
      procedures = Procedure.where("domaine_id=#{@domaine} and version_id = #{version_id} and funcandscreen_id = #{func_id}").all
      procdata = ""
      procedures.each do |procedure|
        parameters = procedure.parameters.to_s.split("|$|")
        procparam = ""
        procparamvalorised = ""
        for i in 0..parameters.length-1
          if (i)%2 == 0
            if procparam != ""
              procparam += " , "
              procparamvalorised += " , "
            end
            procparam += parameters[i]
            procparamvalorised += '#{' + parameters[i] + '}'
          end
        end
        procdata += "\ndef proc_#{procedure.id}(#{procparam})\n##{procedure.name}\n"
		procdata += "	\nif $stopthatalfyftestrigthnow == nil\n"
        procdata += "	$nbfailprocedure = 0\n"
        procdata += "	$currentprocid = #{procedure.id}\n"
        procdata += "	$currentprocname = \"#{procedure.name}\"\n"
        procdata += "	$currentactioncid = nil\n"
        procdata += "	$currentactionname = nil\n"
        procdata += "	$currentsteplevel = \"procedure\"\n"
        if procparam != ""
          procdata += "	$currentparams=\" (#{procparam}) = (#{procparamvalorised}) \"\n"
        else
          procdata += "	$currentparams=\"\"\n"
        end
        procdata += "	$report.log(\"start\")\n"
        procdata += "	begin\n"
		if procedure.code.to_s.strip == ""
			procdata += "		\n$report.fail('', 'missing code')\n"
		else
			proccode = procedure.code.to_s.gsub("$action", "@action").gsub("$domelement", "@domelement").gsub("\r","\n")
			begin
			proccode = proccode.gsub("\n\n","\n")
			end while proccode.index("\n\n") != nil
			procdata += proccode
		end
        procdata += "\n		$report.log(\"endproc\")\n"
        procdata += "	rescue Exception => e\n"
        procdata += "		$report.fail('', e.message)\n"
        procdata += "		$report.log(\"endproc\")\n"
        procdata += "	end\n"
        procdata += "\n	end\nend\n\n"
      end
	  return procdata
  end


  def getactions
    version_id = params[:version_id]
    hostrequest = params[:hostrequest]
    computer = Computer.where(:hostrequest => hostrequest, :guid => params[:guid]).first
    if computer != nil
      @domaine = computer.domaine_id

      actions = Action.where("domaine_id=#{@domaine} and version_id = #{version_id}").all

      data = ""
      actions.each do |action|
        addlineforreport = "\n"
        addlineforreport += "$currentactioncid = #{action.id}\n"
        addlineforreport += "$currentactionname = \"#{action.name}\"\n"
        addlineforreport += "$currentsteplevel = \"action\"\n"
        parameters = action.parameters.to_s.split("|$|")
        actparam = ""
        currentparams = "$currentparams=''\n"
        for i in 0..parameters.length-1
          if (i+1)%2 == 0
            if actparam != ""
              actparam += " , "
            end
            actparam += parameters[i]
            currentparams += "begin\n$currentparams += \"[\" + #{parameters[i]}.name + \"]\" + ' '\nrescue\n$currentparams += '\"' + #{parameters[i]}.to_s + '\" '\nend\n"
          end
        end
        addlineforreport += currentparams
        data += "\ndef #{action.name}(#{actparam})\n"
		data += "\nif $stopthatalfyftestrigthnow == nil\n"
        if action.code.to_s.include? "$report."
			procaction =  action.code.to_s.gsub("$report.", "#{addlineforreport}$report.").gsub("\r","\n")
			begin
			procaction = procaction.gsub("\n\n","\n")
			end while procaction.index("\n\n") != nil
          data += procaction
        else
		  procaction =  action.code.to_s.gsub("\r","\n")
		  begin
			procaction = procaction.gsub("\n\n","\n")
		  end while procaction.index("\n\n") != nil
          data += procaction
        end
        data += "\nend\nend\n\n"
      end
	  saveLastGet("action", version_id, hostrequest)
      render json: data.force_encoding("UTF-8"), status: '200'
    else
      render json: '404', status: '404'
    end
  end


  def gettests
    version_id = params[:version_id]
    hostrequest = params[:hostrequest]
    computer = Computer.where(:hostrequest => hostrequest, :guid => params[:guid]).first
    if computer != nil
      @domaine = computer.domaine_id

      alldata = []
	  params[:testids].split(",").each do |testid|
        test = Test.where(:id => testid).first
		seq = 0
		arrayheader = []
		arrayvalue = []
		initfuncandscreen = []
		inittests = []
		initfuncandscreenstring = ""
		strtestparam = test.parameters.to_s.split("|$|")
		if strtestparam != nil
			for i in 0..strtestparam.length-1
				strtestparam[i] = cvtasparam(strtestparam[i])
			end
			strtestparam = "(#{strtestparam.join(" , ")})"
		end
        data = "class Test#{test.id}\n"
		data += "##{test.name}\n"
		data += "	def execute#{strtestparam}\n"
		if test.is_atdd.to_s != "2"
			data += "		$nbfailtest = 0\n"
			data += "		$nbfailatddtest = 0\n"
			data += "		$currenttestid = #{test.id}\n"
			data += "		$currentatddtestid = 0\n"
			data += "		$currenttestname = \"#{test.name.gsub("\"", "\\\"")}\"\n"
			data += "		$currentprocid = nil\n"
			data += "		$currentprocname = nil\n"
			data += "		$currentprocsequence = nil\n"
			data += "		$currentatddsequence = nil\n"
			data += "		$currentactioncid = nil\n"
			data += "		$currentactionname = nil\n"
			data += "		$currentsteplevel = \"test\"\n"
			data += "		$currentparams=nil\n"
		else
			data += "		$nbfailatddtest = 0\n"
			data += "		$currentatddtestid = #{test.id}\n"
			data += "		$currenttestname = \"#{test.name.gsub("\"", "\\\"")}\"\n"
			data += "		$currentprocid = nil\n"
			data += "		$currentprocname = nil\n"
			data += "		$currentprocsequence = nil\n"
			data += "		$currentactioncid = nil\n"
			data += "		$currentactionname = nil\n"
			data += "		$currentsteplevel = \"atddtest\"\n"
			data += "		$currentparams=nil\n"
		end
		data += "		$report.log(\"start\")\n"
		data += "		\nif $stopthatalfyftestrigthnow == nil\n"
		data += "			#funcscreen initialiazation"
        data += "			begin\n"
		data += "				seq = 0\n"
        data += "				#debut-alfyft-step\n"
        teststeps = TestStep.select("test_steps.*, procedures.name as procname, procedures.return_values as return_values, procedures.funcandscreen_id as func_id")
        .joins("LEFT OUTER JOIN procedures on procedures.id = test_steps.procedure_id")
        .where("test_steps.domaine_id = #{@domaine} and test_steps.test_id = #{test.id} and test_steps.hold is null and test_steps.temporary is null").order(:sequence).all
        outputparameters = ""
		teststeps.each do |step|
          returnstring = ""
          if step.return_values.to_s != ""
            returnvals = step.return_values.to_s.split("|$|")
            for i in 0..returnvals.length-1
              if i%2 == 0
                if i > 0 then returnstring += ", " + returnvals[i] else returnstring += returnvals[i] end
				outputparameters += "," + returnvals[i] + ","
              end
            end
          end

          paramproc = ""
          parameters = (step.parameters.to_s + ".").to_s.split('|$|')
          for i in 0..parameters.length-2
            if i > 0
              paramproc += " , "
            end
            if test.is_atdd.to_s == "2" and test.description.to_s.index("#{parameters[i]}") != nil
              paramproc += "_#{parameters[i]}"
            else
              if parameters[i][0] != '$' and parameters[i][0] != '"' and outputparameters.index("," + parameters[i] + ",") == nil and test.description.to_s.index("<#{parameters[i]}>") == nil
  			           paramproc += "\"" + parameters[i].gsub("\n", "\\n").gsub("\"", "\\\"") + "\""
              else
  			           if parameters[i][0] == '$' or parameters[i][0] == '"' or outputparameters.index("," + parameters[i] + ",") != nil
  				               paramproc += parameters[i].gsub("\n", "\\n").gsub("\"", "\\\"")
  			           else
  				               paramproc += cvtasparam(parameters[i]) #à voir remplacer blanc et accent
  			           end
              end
            end
          end
          if test.is_atdd.to_s != "1"
			data += "				$currentprocsequence = seq + #{step.sequence}\n"
		  else
			data += "				$currentatddsequence = seq + #{step.sequence}\n"
		  end
		  if returnstring != ""
		  if initfuncandscreen.index(step.func_id) == nil then initfuncandscreen << step.func_id end
          data +=  "				#{returnstring} = funcandscreen#{step.func_id}.proc_#{step.procedure_id}(#{paramproc}) ##{step.procname}\n"
          else
			if step.type_code == "comment" or step.type_code == "commentodo"
				data += "				$report.comment(\"#{step.code.gsub("\"", "'")}\")\n"
			else
				if step.procedure_id != nil
					if initfuncandscreen.index(step.func_id) == nil then initfuncandscreen << step.func_id end
					data += "				funcandscreen#{step.func_id}.proc_#{step.procedure_id}(#{paramproc}) ##{step.procname}\n"
				else
					if step.atdd_test_id != nil
						code = step.code.to_s.split("|$|")[1]
						atddparamvalo = step.parameters.to_s.split('|$|')
						pnames = []
						pvalues = []
						alfyft_atdd_step_description = "#{code.gsub("\n", "").gsub("\"", "\\\"")}"
						arguments = code.scan(/arg(\d+)/)
						if arguments!=nil && arguments.length>0
							for i in 0..arguments.length-1
								pnames << "arg#{arguments[i][0]}"
								if atddparamvalo.length > i then pvalues << atddparamvalo[i] else pvalues << "" end
							end
						end

						tparam = []
						for i in 0..pvalues.length-1
						  if pvalues[i].to_s[0] != '$' and pvalues[i].to_s[0] != '"'
							tparam[i] = "\"#{pvalues[i].to_s}\""
							alfyft_atdd_step_description = alfyft_atdd_step_description.sub("#{pnames[i]}", "#{pvalues[i]}")
						  else
							tparam[i] = "#{pvalues[i].to_s}"
							alfyft_atdd_step_description = alfyft_atdd_step_description.sub("#{pnames[i]}", "\#{#{tparam[i]}}")
						  end
						end
						data += "				##{step.code.gsub("\n", "")}\n"
						alfyft_atdd_step_description = "				$alfyft_atdd_step_description = \"#{step.type_code} #{alfyft_atdd_step_description}\"\n"
						data += alfyft_atdd_step_description

						if inittests.index(step.atdd_test_id) == nil then inittests << step.atdd_test_id end
						data += "				test#{step.atdd_test_id}.execute(#{tparam.join(" , ")}) \n"
					else
						if step.type_code.to_s == "ATDDarray"
							code = step.code.to_s.split("\n")
							for i in 0..code.length-1
								if code[i].strip.gsub("\n","").gsub("\r","") != "Examples:" && code[i].strip.gsub("\n","").gsub("\r","") != ""
									arrayline = code[i].strip[1..-1].gsub("\n","").gsub("\r","").to_s.split("|").map(&:strip)
									if arrayheader == []
										arrayheader = arrayline
									else
										if code[i].strip != "" then
											ali = 0
											arrayline.each do |line|
												if line[0] == "$" then
													line = "chardiese{#{line}}"
													arrayline[ali] = line
												end
												ali += 1
											end
											arrayvalue << arrayline
										end
									end
								end
							end
						else
							if step.code.to_s[0] == "#" then 
								data += "				#{step.code.gsub("\n", "")}\n" 
							else 
								code = step.code.to_s
								arguments = test.parameters.to_s.split("|$|")
								if arguments!=nil && arguments.length>0
									for i in 0..arguments.length-1
										if arguments[arguments.length-1-i].start_with? "arg" then
											code = code.gsub("#{arguments[arguments.length-1-i]}", "_#{arguments[arguments.length-1-i]}")
											code = code.gsub("__#{arguments[arguments.length-1-i]}", "_#{arguments[arguments.length-1-i]}")
										end
									end
								end
								data += "				#{code}\n" 
							end
						end
					end
				end
			end
          end
        end
		if arrayheader != []
			bouclearray = "#debut-alfyft-step\n"
			bouclearray += "test_values_name =  " + arrayheader.to_s + "\n"
			bouclearray += "test_values = " + arrayvalue.to_s.gsub("chardiese", "#") + "\n"
			bouclearray += "for nb_test_values in 0..test_values.length-1\n"
			for i in 0..arrayheader.length-1
				bouclearray += "#{cvtasparam(arrayheader[i])} = (test_values_name.index(\"#{arrayheader[i]}\") != nil ? \"\#{test_values[nb_test_values][test_values_name.index(\"#{arrayheader[i]}\")]}\" : \"\")\n"
				data = data.gsub("\"#{arrayheader[i]}\"","#{cvtasparam(arrayheader[i])}")
				data = data.gsub("record[#{arrayheader[i]}]","#{cvtasparam(arrayheader[i])}")
				data = data.gsub("<#{arrayheader[i]}>","\#{#{cvtasparam(arrayheader[i])}}")
			end
			data = data.gsub("				#debut-alfyft-step", bouclearray)
			data += "				seq += 10\nend\n"
		end
		data += "				#fin-alfyft-step\n"
		if teststeps.length == 0 then
			data += "				$currentsteplevel = 'procedure'\n"
			data += "				$report.fail('', 'no step defined')\n"
		end
        if test.is_atdd.to_s != "2"
			data += "				$report.log(\"endtest\")\n"
			data += "			rescue Exception => e\n"
			data += "				$report.fail('', e.message)\n"
			data += "				$report.log(\"endtest\")\n"
			data += "			end\n"
			data += "		end\n	end\nend\n"
		else
			data += "				$report.log(\"endatddtest\")\n"
			data += "			rescue Exception => e\n"
			data += "				$report.fail('', e.message)\n"
			data += "				$report.log(\"endatddtest\")\n"
			data += "			end\n"
			data += "		end\n	end\nend\n"
		end
		initfuncandscreen.each do |initfunc|
			initfuncandscreenstring += "require_relative \"./FuncAndScreen#{initfunc}.rb\"\nfuncandscreen#{initfunc} = FuncAndScreen#{initfunc}.new\n"
		end
		inittests.each do |inittest|
			initfuncandscreenstring += "require_relative \"./Test#{inittest}.rb\"\ntest#{inittest} = Test#{inittest}.new\n"
		end
		data = data.gsub("#funcscreen initialiazation", initfuncandscreenstring)
		alldata << JSON.generate({:name => "Test#{testid}", :code => data.force_encoding("UTF-8")})
		saveLastGet("Test#{testid}", version_id, hostrequest)
	  end
      render json: alldata, status: '200'
    else
      render json: '404', status: '404'
    end
  end



  def getruncode
    hostrequest = params[:hostrequest]
    computer = Computer.where(:hostrequest => hostrequest, :guid => params[:guid]).first
    if computer != nil
      run = Run.where(:id => params[:run_id]).first
      render json: run.exec_code.to_s.force_encoding("UTF-8"), status: '200'
    else
      render json: '404', status: '404'
    end
  end


  def unlocksubrun
    rid, uuid = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    aut = RunAuthentication.where(:run_id => rid, :uuid => uuid).first
    if aut != nil
	  runencours = Run.where(:domaine_id => aut.domaine_id, :id => rid).first
	  if runencours.status == "ended"
		render json: 'kill', status: '200'
	  else
		  if params["id"] != nil
			run = Run.where(:id => params["id"]).first
			if run != nil and run.status == 'blocked'
			  run.status = 'startable'
			  run.save
			end
		  end
		  render json: '200', status: '200'
		end
    else
      render json: '404', status: '404'
    end
  end

  def getnodestatus
    rid, uuid = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    aut = RunAuthentication.where(:run_id => rid, :uuid => uuid).first
    if aut != nil
	  runencours = Run.where(:domaine_id => aut.domaine_id, :id => rid).first
	  if runencours.status == "ended"
		render json: 'kill', status: '200'
	  else
		  runstatus = ""
		  if params["id"] != nil and params["node"] != nil
			runendednode = RunEndedNode.where(:domaine_id => aut.domaine_id, :run_id => params["id"], :test_node_id_externe => params["node"]).first
			if runendednode != nil
			  runstatus = 'ended'
			end
		  end
			render json: runstatus, status: '200'
	  end
    else
      render json: '404', status: '404'
    end
  end

  def getsuitestatus
    rid, uuid = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    aut = RunAuthentication.where(:run_id => rid, :uuid => uuid).first
    if aut != nil
	  runencours = Run.where(:domaine_id => aut.domaine_id, :id => rid).first
	  if runencours.status == "ended"
		render json: 'kill', status: '200'
	  else
		  result = ""
		  if params["id"] != nil
			run = Run.where(:id => params["id"]).first
			if run != nil
			  result = run.status
			end
		  end
		  render json: "{\"status\":\"#{result}\"}", status: '200'
	   end
    else
      render json: '404', status: '404'
    end
  end


  def postresult
  begin
	payload = ""
    rid, uuid = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    aut = RunAuthentication.where(:run_id => rid, :uuid => uuid).first
	nb=0
	params["_json"].each do |paramj|
		paramjson = JSON.parse(paramj, :quirks_mode => true)
		nb+=1
			if paramjson["result"].to_s != "endrun" and paramjson["run_father_id"].to_s != ""
			  run_id = paramjson["run_father_id"]
			else
			  run_id = paramjson["run_id"]
			end
			if aut != nil
			  run = Run.where(:domaine_id => aut.domaine_id, :id => paramjson["run_id"]).first
			  if run != nil
				  if paramjson["result"].to_s == "endproc" or paramjson["result"].to_s == "endatddtest" or paramjson["result"].to_s == "endtest" or paramjson["result"].to_s == "endrun"
					if paramjson["result"].to_s == "endproc"
					  runstepresult = RunStepResult.where(:domaine_id => aut.domaine_id,
						:run_id => run_id,
						:suite_id => paramjson["suite_id"].to_s.to_i,
						:suite_sequence => paramjson["suite_sequence"].to_s.to_i,
						:test_id => paramjson["test_id"].to_s.to_i,
						:test_node_id_externe => paramjson["test_node_id_externe"].to_s.to_i,
						:proc_id => paramjson["proc_id"].to_s.to_i,
						:proc_sequence => paramjson["proc_sequence"].to_s.to_i,
						:atdd_sequence => paramjson["atdd_sequence"].to_s.to_i,
						:steplevel => "procedure",
						:result => 'start').first
					  if runstepresult != nil
						if paramjson["detail"].to_s == "PASS"
						  runstepresult.result = "PASS"
						  tentative = 0
						  begin
							saved = runstepresult.save
						  rescue
							tentative += 1
						  end until (saved or tentative > 1000)
						else
						  Run.where(:id => run_id).update_all("nbprocfail = nbprocfail + 1")
						  runstepresult.result = "FAIL"
						  runstepresult.detail = paramjson["detail"].to_s
						  tentative = 0
						  begin
							saved = runstepresult.save
						  rescue
							tentative += 1
						  end until (saved or tentative > 1000)
						end
					  end
					end
					if paramjson["result"].to_s == "endatddtest"
					  runstepresult = RunStepResult.where(:domaine_id => aut.domaine_id,
						:run_id => run_id,
						:suite_id => paramjson["suite_id"].to_s.to_i,
						:suite_sequence => paramjson["suite_sequence"].to_s.to_i,
						:test_id => paramjson["test_id"].to_s.to_i,
						:test_node_id_externe => paramjson["test_node_id_externe"].to_s.to_i,
						:proc_id => 0,
						:proc_sequence => 0,
						:atdd_sequence => paramjson["atdd_sequence"].to_s.to_i,
						:steplevel => "atddtest",
						:result => 'start').first
					  if runstepresult != nil
						Test.where(:id => paramjson["test_id"]).update_all(:lastresult => paramjson["detail"].to_s[0..49])
						if paramjson["detail"].to_s == "PASS"
						  runstepresult.result = "PASS"
						  tentative = 0
						  begin
							saved = runstepresult.save
							rescue
							tentative += 1
						  end until (saved or tentative > 1000)
						else
						  runstepresult.result = paramjson["detail"].to_s
						  tentative = 0
						  begin
							saved = runstepresult.save
							rescue
							tentative += 1
						  end until (saved or tentative > 1000)
						end
					  end
					end
					if paramjson["result"].to_s == "endtest"
					  runendednode = RunEndedNode.new(:domaine_id => aut.domaine_id,
						:run_id => run_id,
						:test_node_id_externe => paramjson["test_node_id_externe"].to_s.to_i)
					  runendednode.save
					  runstepresult = RunStepResult.where(:domaine_id => aut.domaine_id,
						:run_id => run_id,
						:suite_id => paramjson["suite_id"].to_s.to_i,
						:suite_sequence => paramjson["suite_sequence"].to_s.to_i,
						:test_id => paramjson["test_id"].to_s.to_i,
						:test_node_id_externe => paramjson["test_node_id_externe"].to_s.to_i,
						:proc_id => 0,
						:proc_sequence => 0,
						:atdd_sequence => 0,
						:steplevel => "test",
						:result => 'start').first
					  if runstepresult != nil
						test = Test.where(:id => paramjson["test_id"]).first
					    test.lastresult = paramjson["detail"].to_s[0..49]
						test.save
						if test.fiche_id != nil then Fiche.where(:id => test.fiche_id).update_all(:lastresult => paramjson["detail"].to_s[0..49]) end
						if paramjson["detail"].to_s == "PASS"
						 Run.where(:id => run_id).update_all("nbtestpass = nbtestpass + 1")
						  runstepresult.result = "PASS"
						  tentative = 0
						  begin
							saved = runstepresult.save
							rescue
							tentative += 1
						  end until (saved or tentative > 1000)
						else
						  Run.where(:id => run_id).update_all("nbtestfail = nbtestfail + 1")
						  runstepresult.result = paramjson["detail"].to_s
						  tentative = 0
						  begin
							saved = runstepresult.save
							rescue
							tentative += 1
						  end until (saved or tentative > 1000)
						end
					  end
					end
					if paramjson["result"].to_s == "endrun"
					  runstepresult = RunStepResult.where(:domaine_id => aut.domaine_id,
						:run_id => run_id,
						:suite_id => paramjson["suite_id"].to_s.to_i,
						:suite_sequence => paramjson["suite_sequence"].to_s.to_i,
						:test_id => 0,
						:test_node_id_externe => 0,
						:proc_id => 0,
						:proc_sequence => 0,
						:atdd_sequence => 0,
						:steplevel => "suite",
						:result => 'start').first
					  if runstepresult != nil
						runstepresultfail = RunStepResult.where(:domaine_id => aut.domaine_id,
						:run_id => run_id,
						:suite_id => paramjson["suite_id"].to_s.to_i,
						:suite_sequence => paramjson["suite_sequence"].to_s.to_i,
						:steplevel => "procedure",
						:result => 'FAIL').all
						runstepresultpass = RunStepResult.where(:domaine_id => aut.domaine_id,
						:run_id => run_id,
						:suite_id => paramjson["suite_id"].to_s.to_i,
						:suite_sequence => paramjson["suite_sequence"].to_s.to_i,
						:steplevel => "procedure",
						:result => 'PASS').all
						runstepresult.result = "FAIL : #{runstepresultfail.length}"

						if runstepresultfail.length == 0 and runstepresultpass.length == 0
							runstepresult.result = 'NORUN'
						else
							if runstepresultfail.length == 0
								runstepresult.result = "PASS"
							else
								runstepresult.result = "FAIL : #{runstepresultfail.length}"
							end
						end
						tentative = 0
						begin
						  saved = runstepresult.save
						rescue
						  tentative += 1
						end until (saved or tentative > 1000)

					  end
					  if run != nil
						RunEndedNode.where(:domaine_id => aut.domaine_id, :run_id => paramjson["run_id"]).delete_all
						RunAuthentication.where(:run_id => paramjson["run_id"]).delete_all
						RunStoreDatum.where(:domaine_id => aut.domaine_id, :run_id => paramjson["run_id"]).delete_all
						run.status = "ended"
						run.save
						Run.where(:domaine_id => aut.domaine_id, :run_father_id => run.id).update_all(:status => "ended")
						lockruns = Run.where(:domaine_id => aut.domaine_id, :unlock_run_id => paramjson["run_id"]).all
						if lockruns != nil
						  lockruns.each do |lockrun|
							if lockrun.status == 'blocked'
							  lockrun.status = 'startable'
							  lockrun.save
							end
						  end
						end

						updatefailpassrunscheme(run)
					  end
					end
				  else
					dolog = true
					if paramjson["result"].to_s == 'start' and paramjson["steplevel"].to_s == "suite" and RunStepResult.where(:domaine => aut.domaine_id, :run_id => run_id).first != nil then dolog = false end
					if dolog
						resultlog = RunStepResult.new
						resultlog.run_id = run_id
						resultlog.domaine_id = aut.domaine_id
						resultlog.suite_id = paramjson["suite_id"].to_s.to_i
						resultlog.suite_sequence = paramjson["suite_sequence"].to_s.to_i
						resultlog.test_id = paramjson["test_id"].to_s.to_i
						resultlog.atdd_test_id = paramjson["atddtest_id"].to_s.to_i
						resultlog.test_node_id_externe = paramjson["test_node_id_externe"].to_s.to_i
						resultlog.proc_id = paramjson["proc_id"].to_s.to_i
						resultlog.proc_sequence = paramjson["proc_sequence"].to_s.to_i
						resultlog.atdd_sequence = paramjson["atdd_sequence"].to_s.to_i
						resultlog.action_id = paramjson["action_id"].to_s.to_i
						resultlog.suite_name = (paramjson["suite_name"].to_s)[0..250]
						resultlog.test_name = (paramjson["test_name"].to_s)[0..250]
						resultlog.proc_name = (paramjson["proc_name"].to_s)[0..250]
						resultlog.action_name = (paramjson["action_name"].to_s)[0..60]
						resultlog.params = (paramjson["parameters"].to_s)[0..1024]
						resultlog.steplevel = (paramjson["steplevel"].to_s)[0..20]
						resultlog.detail = paramjson["detail"].to_s
						resultlog.expected = paramjson["expected"].to_s
						resultlog.result = (paramjson["result"].to_s)[0..50]
						tentative = 0
						begin
						saved = resultlog.save
						rescue
						tentative += 1
						end until (saved or tentative > 1000)

						if paramjson["steplevel"] == 'photo'
							#Thread.new do
							#	RunscreenshotJob.perform_later(aut.domaine_id, run_id, paramjson["screenshotuid"], paramjson["screenshotname"], paramjson["suite_id"], paramjson["test_id"], paramjson["proc_id"], paramjson["test_node_id_externe"], paramjson["stringconfig"], paramjson["screenshotdata"], paramjson["compare"])
							#end
							refimage, imageid  = store_image_and_return_ref(aut.domaine_id, run_id, paramjson["screenshotuid"], paramjson["screenshotname"], paramjson["suite_id"], paramjson["test_id"], paramjson["proc_id"], paramjson["test_node_id_externe"], paramjson["stringconfig"], paramjson["screenshotdata"], paramjson["compare"])
							payloadh = {:refpng => "#{refimage}",
										:imageid => "#{imageid}"}
							payload = JSON.generate(payloadh)
						end
						if paramjson["steplevel"] == 'diffphoto'
							store_image_diff(aut.domaine_id, run_id, paramjson["screenshotuid"], paramjson["compare"], paramjson["result"], paramjson["screenshotdata"])
						end
					end
				  end
				  if run.status == "ended" and paramjson["result"].to_s != "endrun" then
					payload = "kill"
				  end
				else
				  payload = "kill"
				end
			else
			  payload = "kill"
			end
		end
	rescue Exception => e
	Rails.logger.error e.message
	end
	render json: payload, status: '200'
  end


  def updatefailpassrunscheme(run)
    runsuiteschemes = RunSuiteScheme.where(:domaine_id => run.domaine_id, :run_id => run.id).all
    runsuiteschemes.each do |suitescheme|
      if suitescheme.sequence == nil
        filtreseq = "run_step_results.suite_sequence is null"
      else
        filtreseq = "run_step_results.suite_sequence = #{suitescheme.sequence}"
      end
      nodenbprocpassfails = RunStepResult.select("test_node_id_externe, sum(case when result='PASS' then 1 else 0 end) as nbpass, sum(case when result='FAIL' then 1 else 0 end) as nbfail")
      .where("run_step_results.domaine_id = #{run.domaine_id} and run_step_results.run_id = #{run.id}  and run_step_results.suite_id = #{suitescheme.suite_id}  and #{filtreseq} and steplevel='procedure'").group("test_node_id_externe").all
      nodenbprocpassfails.each do |nodenbprocpassfail|
        suitescheme.jsonnode = suitescheme.jsonnode.gsub("$nbprocpass#{nodenbprocpassfail.test_node_id_externe}$", "#{nodenbprocpassfail.nbpass}").gsub("$nbprocfail#{nodenbprocpassfail.test_node_id_externe}$", "#{nodenbprocpassfail.nbfail}")
        suitescheme.save
      end
    end
  end


  def storedata
    rid, uuid = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    aut = RunAuthentication.where(:run_id => rid, :uuid => uuid).first
    if aut != nil
      key = params["key"].to_s
      value = params["value"].to_s
      storeddata = RunStoreDatum.where(:domaine_id => aut.domaine_id, :run_id => rid, :key => key).first
      if storeddata == nil then
        storeddata = RunStoreDatum.new
        storeddata.domaine_id = aut.domaine_id
        storeddata.run_id = rid
        storeddata.key = key
      end
      storeddata.value = value
      storeddata.save
    end
    render json: '200', status: '200'
  end

  def getdata
    rid, uuid = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    aut = RunAuthentication.where(:run_id => rid, :uuid => uuid).first
    value = ""
    if aut != nil
      key = params["key"].to_s
      storeddata = RunStoreDatum.where(:domaine_id => aut.domaine_id, :run_id => rid, :key => key).first
      if storeddata != nil then
        value = storeddata.value
      end
    end
    render json: "{\"value\":\"" + value.gsub("\n","\\n") + "\"}", status: '200'
  end


  def uploadimage
	maxsize = 50000

	contenttype = request.headers["Content-Type"]
	contenttype = contenttype[contenttype.index('/')+1..contenttype.length-1]
	newfilename = "img#{SecureRandom.uuid}." + contenttype
	imgfile = File.open("./public/images/#{newfilename}", "wb")
	if contenttype.upcase == "PNG"
		image = MiniMagick::Image.read(request.body.read)
		size = image.size
		if size > maxsize
			reduc = Math.sqrt(size/maxsize)
			l = image.dimensions[0]/reduc
			h = image.dimensions[1]/reduc
			image.resize("#{l.to_i}x#{h.to_i}")
		end
	else
		image = request.body.read
	end
	scaled_image_bytes = image.to_blob

	imgfile.puts scaled_image_bytes

	imgfile.close

	render json: newfilename, status: '200'
end


def store_image_and_return_ref(domaine_id, run_id, screenshotuid, screenshotname, psuite_id, ptest_id, pproc_id, test_node_id_externe, stringconfig, screenshotdata, compare)
  refpng = ""
  resultimage = RunScreenshot.new
  resultimage.domaine_id = domaine_id
  resultimage.guid = screenshotuid
  resultimage.run_id = run_id
  resultimage.name = screenshotname
  suite_id = ""
  test_id = ""
  proc_id = ""
  if psuite_id.to_s != ""
	suite = Sheet.where(:id => psuite_id).first
	if suite != nil then suite_id = suite.current_id.to_s end
  end
  if ptest_id.to_s != ""
	test = Test.where(:id => ptest_id).first
	if test != nil then test_id = test.current_id.to_s end
  end
  if pproc_id.to_s != ""
	proc = Procedure.where(:id => pproc_id).first
	if proc != nil then proc_id = proc.current_id.to_s end
  end
  location = suite_id + "_" + test_id + "_" + test_node_id_externe.to_s + "_" + proc_id
  resultimage.location = location
  resultimage.configstring = stringconfig
  resultimage.pngname = "#{domaine_id}_#{screenshotuid}.png" #Base64.decode64(screenshotdata)
  resultimage.type_screenshot = 'last'
  tentative = 0
  newfile = File.open("./public/screenshots/#{domaine_id}_#{screenshotuid}.png", "wb")
  scaled_bytes = Base64.decode64(screenshotdata)
  newfile.puts scaled_bytes
  newfile.close
  begin
  saved = resultimage.save
  rescue
  tentative += 1
  end until (saved or tentative > 1000)
  if screenshotname != "run_step_error"
	  refimage = RefScreenshot.where(:name => screenshotname, :configstring => stringconfig, :location => location).first
	  if refimage == nil or (File.exists?("./public/screenshots/#{refimage.pngname}")==false)
		if refimage == nil then refimage = RefScreenshot.new end
		refimage.domaine_id = domaine_id
		refimage.name = resultimage.name
		refimage.configstring = resultimage.configstring
		refimage.location = resultimage.location
		refimage.pngname = "ref_#{domaine_id}_#{screenshotuid}.png" #resultimage.data64
		tentative = 0
		newfile = File.open("./public/screenshots/ref_#{domaine_id}_#{screenshotuid}.png", "wb")
		scaled_bytes = Base64.decode64(screenshotdata)
		newfile.puts scaled_bytes
		newfile.close
		begin
		  saved = refimage.save
		rescue
		  tentative += 1
		end until (saved or tentative > 1000)
	  else
		if compare.to_s == "true"
		 refpng = File.open("./public/screenshots/#{refimage.pngname}", "rb").read
		 refpng = Base64.encode64(refpng)
		end
	  end
  end
  return refpng, resultimage.id
end

def store_image_diff(domaine_id, run_id, screenshotuid, imageid, pourcentagechange, png_data)
	pourcentagechange = pourcentagechange.to_f * 1.000
	resultimage = RunScreenshot.where(:id => imageid).first
	diffimage = resultimage.dup
	if pourcentagechange < 0.001 then diffimage.has_diff = 0 else diffimage.has_diff = 1 end
	diffimage.pngname = "diff_#{domaine_id}_#{screenshotuid}.png" #png_data
	diffimage.type_screenshot = 'diff'
	diffimage.prct_diff = (pourcentagechange * 100).to_i
	tentative = 0
	newfile = File.open("./public/screenshots/diff_#{domaine_id}_#{screenshotuid}.png", "wb")
	scaled_bytes = Base64.decode64(png_data)
	newfile.puts scaled_bytes
	newfile.close
	begin
		saved = diffimage.save
	rescue Exception => e
		tentative += 1
		Rails.logger.error e.message
	end until (saved or tentative > 1000)

	run_screenshot_diff = RunScreenshot.select("count(1) as nb").where(:domaine_id => domaine_id, :run_id => run_id, :type_screenshot => 'diff', :has_diff => 1).first
	if run_screenshot_diff != nil
		run = Run.where(:id => run_id).first
		if run != nil
			run.nb_screenshots_diffs = run_screenshot_diff.nb
			run.save
		end
	end

end

def cvtasparam(str)
	str = "_" + str.downcase
	retour = ""
	keepchar = "0123456789abcdefghijklmnopqrstuvwxyz_"
	for i in 0..str.length-1
		if keepchar.index(str[i]) != nil then retour += str[i] end
	end
	return retour
end



end
