# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module Commun

def Commun.get_encrypted_password(pwd)
	  _encryptedpassword = Base64.urlsafe_encode64(pwd)
      _encryptedpassword = OpenSSL::HMAC.digest('SHA256', 'vt5d4fd', _encryptedpassword) 
      _encryptedpassword = Base64.urlsafe_encode64(_encryptedpassword)
	  return _encryptedpassword
end
def Commun.get_variables_string
	stringvariable = "$webdriver$
	$TA$
	$nativeapp$
	$currentactioncid$
	$currentactionname$
	$currentsteplevel$
	$currentparams$
	$nbfailprocedure$
	$currentprocid$
	$currentprocname$
	$nbfailtest$
	$currenttestid$
	$currenttestname$
	$currentprocsequence$
	$report$
	$action$
	$report$
	$urlpostresult$
	$currentrun$
	$currentuuid$
	$currentsuiteid$
	$currentsuitename$
	$stopthatalfyftestrigthnow$
	$nbfailatddtest$
	$currentatddtestid$
	$currentatddsequence$"
	return stringvariable
end

def Commun.set_message(ko)
#@message, @KO, badcode = Commun.set_message(params[:kop])
	ko = ko.to_s
	message = ok = nil
	case ko
    when '0'
      message = I18n.t "message.action_creee"
      ok = true
    when '1'
      message = I18n.t "message.maj_effectuee"
      ok = true
    when '2'
      message = I18n.t "message.action_existante"
      ok = false
    when '3'
      message = I18n.t "message.action_source_existe_plus"
      ok = false
    when '4'
      message = I18n.t "message.suppression_role_impossible"
      ok = false
	when '5'
      message = I18n.t "message.variable_existante"
      ok = false
	when '6'
      message = I18n.t "message.impossible_d_enregistrer_ce_parent"
      ok = false
	when '7'
      message = I18n.t "message.code_existant"
      ok = false
	when '8'
      message = I18n.t "message.suppression_impossible"
      ok = false
	when '9'
      message = I18n.t "message.operation_impossible"
      ok = false
	when '10'
      message = I18n.t "message.role_existant"
      ok = false
	when '11'
      message = I18n.t "message.test_pret_pour_lancement_client"
      ok = true
	when '12'
      message = I18n.t "message.ajouter_le_test_dans_un_repertoire_et_editer"
	  ok = true
	when '13'
      message = I18n.t "message.nom_existant"
	  ok = false
	when '14'
      message = I18n.t "message.mot_de_passe_different"
	  ok = false
	when '15'
      message = I18n.t "message.login_existant"
	  ok = false
	when '16'
      message = I18n.t "message.rien_a_archive"
	  ok = false
	when '17'
      message = I18n.t "message.archivage_termine"
	  ok = true
    when '99'
      message = I18n.t "message.une_erreur_est_survenue"
      ok = false

    end
	return message, ok

end

def Commun.get_variables_and_constantes_names(domaine_id, version_id)
	configurationvariables = ConfigurationVariable.where(:domaine_id => domaine_id).order(:name).all
    environnementvariables = EnvironnementVariable.select("distinct varinit.*")
    .joins("INNER JOIN environnements on environnements.domaine_id = environnement_variables.domaine_id and environnements.id = environnement_variables.environnement_id")
    .joins("INNER JOIN environnement_variables as varinit on environnements.domaine_id = varinit.domaine_id and environnement_variables.init_variable_id = varinit.id")
    .where("environnements.domaine_id = #{domaine_id} and environnements.version_id = #{version_id}").order("varinit.name").all
    data_set_variables = DataSetVariable.select("distinct varinit.*")
    .joins("INNER JOIN data_sets on data_sets.domaine_id = data_set_variables.domaine_id and data_sets.id = data_set_variables.data_set_id")
    .joins("INNER JOIN data_set_variables as varinit on data_sets.domaine_id = varinit.domaine_id and data_set_variables.init_variable_id = varinit.id")
    .where("data_sets.domaine_id = #{domaine_id} and data_sets.version_id = #{version_id}").order("varinit.name").all
    testconstantes = TestConstante.where(:domaine_id => domaine_id).all
	return configurationvariables, environnementvariables, data_set_variables, testconstantes
end


def Commun.saverunsuiteschemes(run)
    if run.suite_id != nil
      sheet = Sheet.where(:domaine_id => run.domaine_id, :id => run.suite_id).first
      if sheet != nil
        jsonnode = "[]"
        jsonlink = "[]"
        nodes = Node.where(:domaine_id => run.domaine_id, :sheet_id => sheet.id).all
        if nodes != nil
          jsonnode = "["
          nodes.each do |node|
            if jsonnode != "["
              jsonnode += ","
            end
			if node.obj_id != nil
				procs = Test.select("count(1) as nb").joins("INNER JOIN test_steps on test_steps.domaine_id = tests.domaine_id and test_steps.test_id = tests.id and procedure_id is not null").where("tests.id = #{node.obj_id}").first
				if procs != nil then nbproctot = procs.nb else nbproctot = 0 end
			else
				nbproctot = 0
			end
			jsonnode += "{\"id_externe\":#{node.id_externe},\"x\":#{node.x},\"y\":#{node.y},\"name\":\"#{node.name}\",\"obj_type\":\"#{node.obj_type}\",\"obj_id\":\"#{node.obj_id}\",\"forced\":\"#{node.forced}\",\"force_type\":\"#{node.force_type}\",\"nbproctot\":\"#{nbproctot}\",\"nbprocpass\":\"$nbprocpass#{node.id_externe}$\",\"nbprocfail\":\"$nbprocfail#{node.id_externe}$\"}"
          end
          jsonnode += "]"
        end
        links = Link.where(:domaine_id => run.domaine_id, :sheet_id => sheet.id).all
        if links != nil
          jsonlink = "["
          links.each do |link|
            if jsonlink != "["
              jsonlink += ","
            end
            if link.curved == nil
              curved = 0
            else
              curved = link.curved
            end
            jsonlink += "{\"node_father_id_fk\":#{link.node_father_id_fk},\"node_son_id_fk\":#{link.node_son_id_fk},\"curved\":\"#{curved}\",\"inflexion_x\":#{link.inflexion_x},\"inflexion_y\":#{link.inflexion_y}}"
          end
          jsonlink += "]"
        end
        if jsonnode != "[]"
          sequence = 0
          if run.campain_test_suite_id != nil
            campain_test_suite = CampainTestSuite.where(:id => run.campain_test_suite_id).first
            if campain_test_suite != nil then sequence = campain_test_suite.sequence end
          end
          runsuitescheme = RunSuiteScheme.new
          runsuitescheme.domaine_id = run.domaine_id
          runsuitescheme.run_id = run.id
          runsuitescheme.suite_id = sheet.id
          runsuitescheme.sequence = sequence
          runsuitescheme.jsonnode = jsonnode
          runsuitescheme.jsonlink = jsonlink
          runsuitescheme.save
        end
      end
    end
  end

  def Commun.set_run_string_config(domaine_id, run_id, node_id, suite_id, suite_name)
    run = Run.where(:id => run_id).first
    version_id = run.version_id
    currentrunfather = run_id
    if run.run_father_id.to_s != ''
      run_configs = RunConfig
      .select("configuration_variables.name as name, case when node_forced_configs.variable_value is not null then node_forced_configs.variable_value else run_configs.variable_value end as value, configuration_variables.is_numeric, configuration_variables.is_boolean")
      .joins("INNER JOIN configuration_variables on configuration_variables.id = run_configs.variable_id")
      .joins("LEFT OUTER JOIN node_forced_configs on node_forced_configs.domaine_id = configuration_variables.domaine_id and node_forced_configs.variable_id = configuration_variables.id and node_forced_configs.node_id = #{node_id}")
      .where(:domaine_id => domaine_id, :run_id => run.run_father_id).all
      currentrunfather = run.run_father_id
    else
      run_configs = RunConfig
      .select("configuration_variables.name as name, case when node_forced_configs.variable_value is not null then node_forced_configs.variable_value else run_configs.variable_value end as value, configuration_variables.is_numeric, configuration_variables.is_boolean")
      .joins("INNER JOIN configuration_variables on configuration_variables.id = run_configs.variable_id")
      .joins("LEFT OUTER JOIN node_forced_configs on node_forced_configs.domaine_id = configuration_variables.domaine_id and node_forced_configs.variable_id = configuration_variables.id and node_forced_configs.node_id = #{node_id}")
      .where(:domaine_id => domaine_id, :run_id => run.id).all
    end
    test_constantes = TestConstante.where(:domaine_id => domaine_id).all
    data = ""
    data += "$currentrun = #{run_id}\n"
	  data += "$currentrunfather = #{currentrunfather}\n"
    data += "$currentsuiteid = #{suite_id}\n"
    data += "$currentsuitename = \"#{suite_name}\"\n"
    if suite_id > 0 then data += "$currentsteplevel = \"suite\"\n" end
    data += "$currentparams=''\n"
    data += "$nbfailsuite=0\n"
    data += "$nbfailtest=0\n"
    data += "$nbfailprocedure=0\n"
    test_constantes.each do |constante|
      if constante.name.to_s != ""
        if (constante.is_numeric.to_s != "1" and constante.is_boolean.to_s != "1") or constante.value.to_s == ""
          data += constante.name + " = \"" + constante.value + "\"" + "\n"
        else
          data += constante.name + " = " + constante.value + "\n"
        end
      end
    end

    configstring = "$configstring = ''"
	  mobiletest = false
    run_configs.each do |config|
      if config.name.to_s != "" and config.value.to_s != ""
        if config.is_numeric.to_s != "1" and config.is_boolean.to_s != "1"
          data += config.name + " = \"" + config.value + "\"" + "\n"
        else
          data += config.name + " = " + config.value + "\n"
        end

        configstring += " + #{config.name}.to_s + '_' "
        if config.name == '$environment'
          environment_variables = EnvironnementVariable
          .select("environnement_variables.*")
          .joins("INNER JOIN environnements on environnements.domaine_id = environnement_variables.domaine_id and environnements.id = environnement_variables.environnement_id ")
          .where("environnement_variables.domaine_id = #{domaine_id} and environnements.version_id = '#{version_id}' and environnements.name = '#{config.value}'").all
          environment_variables.each do |envariable|
            if envariable.name.to_s != "" and envariable.value.to_s != ""
              if envariable.is_numeric.to_s != "1" and envariable.is_boolean.to_s != "1"
                data += envariable.name + " = \"" + envariable.value + "\"" + "\n"
              else
                data += envariable.name + " = " + envariable.value + "" + "\n"
              end
            end
          end
        end
        if config.name == '$data_set'
          data_set_variables = DataSet
          .select("distinct var_jdd_default.name, var_jdd_default.is_numeric, var_jdd_default.is_boolean, case when var_jdd_selected.value is not null and var_jdd_selected.value != '' then var_jdd_selected.value else var_jdd_default.value end as value ")
          .joins("INNER JOIN data_set_variables as var_jdd_default on data_sets.domaine_id = var_jdd_default.domaine_id and data_sets.id = var_jdd_default.data_set_id ")
          .joins("LEFT OUTER JOIN data_sets as selected_set on selected_set.domaine_id = data_sets.domaine_id and selected_set.version_id = data_sets.version_id and selected_set.name = '#{config.value}'")
          .joins("LEFT OUTER JOIN data_set_variables as var_jdd_selected on var_jdd_selected.domaine_id = selected_set.domaine_id and var_jdd_selected.data_set_id = selected_set.id and var_jdd_selected.init_variable_id = var_jdd_default.init_variable_id")
          .where("data_sets.domaine_id = #{domaine_id} and data_sets.version_id = '#{version_id}' and data_sets.is_default = 1").all
          data_set_variables.each do |jddvariable|
            if jddvariable.name.to_s != "" and jddvariable.value.to_s != ""
              if jddvariable.is_numeric.to_s != "1" and jddvariable.is_boolean.to_s != "1"
                data += jddvariable.name + " = \"" + jddvariable.value + "\"" + "\n"
              else
                data += jddvariable.name + " = " + jddvariable.value + "" + "\n"
              end
            else
              if jddvariable.name.to_s != "" then data += jddvariable.name + " = \"" + jddvariable.value.to_s + "\"" + "\n" end
            end
          end
        end

        if config.name == '$execution_test_device' and config.value.include? "Mobile" then mobiletest = true end
        if config.name == '$appium_capabilities' and config.value.to_s != ""
          caps_values = AppiumCapValue
          .select("appium_cap_values.*")
          .joins("INNER JOIN appium_caps on appium_caps.domaine_id = appium_cap_values.domaine_id and appium_caps.id = appium_cap_values.appium_cap_id ").where("appium_cap_values.domaine_id = #{domaine_id} and appium_caps.version_id = '#{version_id}' and appium_caps.name = '#{config.value}'").all
          data += "\ndesired_caps = {\n  caps: {\n"
          ncaps = 0
          caps_values.each do |capvalue|
            ncaps += 1
            if capvalue.name.to_s != "" and capvalue.value.to_s != ""
              if ncaps > 1 then data += ", \n" end
              if capvalue.is_numeric.to_s != "1" and capvalue.is_boolean.to_s != "1"
                data += capvalue.name + ": \"" + capvalue.value.gsub('\\', '\\\\') + "\""
              else
                data += capvalue.name + ": " + capvalue.value
              end
            end
          end
          data += "\n  }\n}\n"
        end
      end
    end
    data = data + "\n" + configstring  + "\n"
    data = data.gsub("\"true\"", "true").gsub("\"false\"", "false").force_encoding("UTF-8")
	  run.conf_string = data
	  if mobiletest and run.run_type = 'WEB' then run.run_type = "MobileWEB" end
	  run.save

  end

  def Commun.add_sub_run(run_id, node_id_ext, node_id, test_id)
        subrun = Run.where(:id => run_id).first.dup
        subrun.run_father_id = run_id
        subrun.start_node_id = node_id_ext
		subrun.status = "blocked"
		subrun.exec_code = "#testclassrequire\n"
		subrun.conf_string = ""
		subrun.unlock_run_id = nil
		forced_computer = NodeForcedComputer.where(:domaine_id => subrun.domaine_id, :node_id => node_id).first
        if forced_computer != nil then subrun.hostrequest = forced_computer.hostrequest end
		test = Test.where(:id => test_id).first
		typetest = ListeValue.where(:id => test.test_type_id).first
		subrun.run_type = typetest.value
        subrun.save
		return subrun
  end


  def Commun.build_sub_run(domaine_id, suite_id, run_id, suite_name)
	startnode = Node.where(:domaine_id => domaine_id, :sheet_id => suite_id, :obj_type => "starttestsuite").first
	@tabnode = []
	@tabsubnode = []
	@tabthread = []
	@tabnode << startnode.id
	@tabthread << run_id
	if startnode != nil
		Commun.set_run_string_config(domaine_id, run_id, startnode.id, suite_id, suite_name)
		Commun.parcours_fils(domaine_id, startnode, suite_id, run_id, suite_name)
	end
	run = Run.where(:id => run_id).first
	@tabsubnode.each do |subnode|
		run.exec_code += "$report.waitendtestnode(#{run.id}, #{subnode})\n"
	end
	run.exec_code += "$report.log('endrun')\n"
	run.save
  end

  def Commun.parcours_fils(domaine_id, node, suite_id, run_id, suite_name)
	links = Link.select("links.*, nodes.id as node_id, nodes.new_thread as new_thread")
	.joins("INNER JOIN nodes on nodes.domaine_id = links.domaine_id and nodes.sheet_id = links.sheet_id and nodes.id_externe = links.node_son_id_fk")
	.where("links.domaine_id = #{domaine_id} and links.sheet_id = #{suite_id} and links.node_father_id_fk = #{node.id_externe} and links.wait_link = 0")
	.order("nodes.new_thread DESC").all

	links.each do |link|
		node_son = Node.where(:id => link.node_id).first
		if node_son != nil
			@tabnode << node_son.id
			@tabsubnode << node_son.id_externe
			if node_son.new_thread.to_s != "1"
				fatherthread = Run.where(:id => @tabthread[@tabnode.index(node.id)]).first
				linkwaits = Link.where(:domaine_id => domaine_id, :sheet_id => suite_id, :node_son_id_fk => node_son.id_externe, :wait_link => 1).all
				if linkwaits != nil
					linkwaits.each do |linkwait|
						fatherthread.exec_code += "$report.waitendtestnode(#{run_id}, #{linkwait.node_father_id_fk})\n"
					end
				end
				test = Test.where(:id => node_son.obj_id).first
				if node_son.hold == nil
					fatherthread.exec_code += "$currenttestnodeid = #{node_son.id_externe}\ntest#{node_son.obj_id}=Test#{node_son.obj_id}.new\ntest#{node_son.obj_id}.execute ##{test.name}\n"
					requirestr = "require_relative \"../Test#{node_son.obj_id}.rb\"\n"
					if fatherthread.exec_code.index(requirestr) == nil then fatherthread.exec_code=fatherthread.exec_code.gsub("#testclassrequire\n","#testclassrequire\n" + requirestr) end
				else
					fatherthread.exec_code += "$currenttestnodeid = #{node_son.id_externe}\n# hold -- test#{node_son.obj_id}.execute ##{test.name}\n"
				end
				fatherthread.save
				@tabthread << fatherthread.id
			else
				subthread = Commun.add_sub_run(run_id, node_son.id_externe, node_son.id, node_son.obj_id)
				if node_son.hold == nil
					subthread.exec_code += "$currenttestnodeid = #{node_son.id_externe}\ntest#{node_son.obj_id}=Test#{node_son.obj_id}.new\ntest#{node_son.obj_id}.execute\n"
					requirestr = "require_relative \"../Test#{node_son.obj_id}.rb\"\n"
					if subthread.exec_code.index(requirestr) == nil then subthread.exec_code=subthread.exec_code.gsub("#testclassrequire\n","#testclassrequire\n" + requirestr) end
				else
					subthread.exec_code += "$currenttestnodeid = #{node_son.id_externe}\n# hold -- test#{node_son.obj_id}.execute\n"
				end
				subthread.save
				Commun.set_run_string_config(domaine_id, subthread.id, node_son.id, suite_id, suite_name)
				@tabthread << subthread.id
				fatherthread = Run.where(:id => @tabthread[@tabnode.index(node.id)]).first
				fatherthread.exec_code += "$report.unlocksubrun(#{subthread.id})\n"
				fatherthread.save
			end
			parcours_fils(domaine_id, node_son, suite_id, run_id, suite_name)
		end
	end
  end

  def Commun.get_func_and_screens(version_id, domaine_id, user_id, filtre)
	if filtre.to_s != "" then
		filtre1 = " and (funcandscreens.name like \"%#{filtre}%\" or sheets.name like \"%#{filtre}%\") "
		filtre2 = " and funcandscreens.name like \"%#{filtre}%\""
	else
		filtre1 = ""
		filtre2 = ""
	end
    existingfunc = Funcandscreen.select("distinct funcandscreens.*, sheets.name as sheet_name")
    .joins("INNER JOIN userprojects on userprojects.domaine_id = funcandscreens.domaine_id and userprojects.project_id = funcandscreens.project_id")
    .joins("INNER JOIN nodes on nodes.domaine_id = funcandscreens.domaine_id and nodes.obj_id = funcandscreens.id and nodes.obj_type='funcscreen'")
    .joins("INNER JOIN sheets on sheets.domaine_id = nodes.domaine_id and sheets.id = nodes.sheet_id and (sheets.private = 0 or sheets.owner_user_id=#{user_id})")
    .where("sheets.version_id = #{version_id} and funcandscreens.domaine_id =  #{domaine_id} and userprojects.user_id = #{user_id} #{filtre1}").order("sheets.name, funcandscreens.name").all
    existing_func_not_linked = Funcandscreen.select("distinct funcandscreens.*")
    .joins("INNER JOIN userprojects on userprojects.domaine_id = funcandscreens.domaine_id and userprojects.project_id = funcandscreens.project_id")
    .where("not exists (select 1 from nodes where nodes.domaine_id = funcandscreens.domaine_id and nodes.obj_id = funcandscreens.id and nodes.obj_type='funcscreen') and funcandscreens.domaine_id =  #{domaine_id} and userprojects.user_id = #{user_id} #{filtre2}")
    .order("funcandscreens.name").all
    return existingfunc, existing_func_not_linked
  end


end
