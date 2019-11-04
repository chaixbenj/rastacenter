# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module Versionning
  def Versionning.version_data_set(domaine_id, currentversion, newversionid)
	  # data_set
    data_sets = DataSet.where(:domaine_id => domaine_id, :version_id => currentversion).all
    data_sets.each do |data_set|
      new_env = data_set.dup
      new_env.version_id = newversionid
      new_env.save
      new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'data_set', :obj_id => new_env.id, :obj_current_id => data_set.id, :version_id => newversionid)
      new_link_version.save
    end
    data_set_variables = DataSetVariable.select('data_set_variables.*')
    .joins("INNER JOIN data_sets on data_sets.domaine_id = data_set_variables.domaine_id and data_sets.id = data_set_variables.data_set_id ")
    .where("data_set_variables.domaine_id = #{domaine_id} and data_sets.version_id = #{currentversion}").order(:init_variable_id).all
    init_var_id = 0
    new_init_var_id = 0
    data_set_variables.each do |data_set_variable|
      if init_var_id != data_set_variable.init_variable_id
        new_init_var = DataSetVariable.where(:id => data_set_variable.init_variable_id).first.dup
        new_init_var.save
        new_init_var_id = new_init_var.id
      end
      new_var = data_set_variable.dup
      new_var.init_variable_id = new_init_var_id
      new_var.data_set_id = DataSet.where(:domaine_id => domaine_id, :version_id => newversionid, :current_id => data_set_variable.data_set_id).first.id
      new_var.save
      init_var_id = data_set_variable.init_variable_id
    end
  end

  def Versionning.version_environnement(domaine_id, currentversion, newversionid)
	  # environnement
    environnements = Environnement.where(:domaine_id => domaine_id, :version_id => currentversion).all
    environnements.each do |environnement|
      new_env = environnement.dup
      new_env.version_id = newversionid
      new_env.save
      new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'environnement', :obj_id => new_env.id, :obj_current_id => environnement.id, :version_id => newversionid)
      new_link_version.save
    end
    environnementvariables = EnvironnementVariable.select('environnement_variables.*')
    .joins("INNER JOIN environnements on environnements.domaine_id = environnement_variables.domaine_id and environnements.id = environnement_variables.environnement_id ")
    .where("environnement_variables.domaine_id = #{domaine_id} and environnements.version_id = #{currentversion}").order(:init_variable_id).all
    init_var_id = 0
    new_init_var_id = 0
    environnementvariables.each do |environnementvariable|
      if init_var_id != environnementvariable.init_variable_id
        new_init_var = EnvironnementVariable.where(:id => environnementvariable.init_variable_id).first.dup
        new_init_var.save
        new_init_var_id = new_init_var.id
      end
      new_var = environnementvariable.dup
      new_var.init_variable_id = new_init_var_id
      new_var.environnement_id = Environnement.where(:domaine_id => domaine_id, :version_id => newversionid, :current_id => environnementvariable.environnement_id).first.id
      new_var.save
      init_var_id = environnementvariable.init_variable_id
    end
  end
  
  def Versionning.version_appiumcap(domaine_id, currentversion, newversionid)
    appium_caps = AppiumCap.where(:domaine_id => domaine_id, :version_id => currentversion).all
    appium_caps.each do |appium_cap|
      new_appium_cap = appium_cap.dup
      new_appium_cap.version_id = newversionid
      new_appium_cap.save
      new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'appium_cap', :obj_id => new_appium_cap.id, :obj_current_id => appium_cap.id, :version_id => newversionid)
      new_link_version.save
    end
    appiumcapvalues = AppiumCapValue.select('appium_cap_values.*')
    .joins("INNER JOIN appium_caps on appium_caps.domaine_id = appium_cap_values.domaine_id and appium_caps.id = appium_cap_values.appium_cap_id ")
    .where("appium_cap_values.domaine_id = #{domaine_id} and appium_caps.version_id = #{currentversion}").order(:init_value_id).all
    init_val_id = 0
    new_init_val_id = 0
    appiumcapvalues.each do |appiumcapvalue|
      if init_val_id != appiumcapvalue.init_value_id
        new_init_val = AppiumCapValue.where(:id => appiumcapvalue.init_value_id).first.dup
        new_init_val.save
        new_init_val_id = new_init_val.id
      end
      new_val = appiumcapvalue.dup
      new_val.init_value_id = new_init_val_id
      new_val.appium_cap_id = AppiumCap.where(:domaine_id => domaine_id, :version_id => newversionid, :current_id => appiumcapvalue.appium_cap_id).first.id
      new_val.save
      init_val_id = appiumcapvalue.init_value_id
    end
  end
  
  
  def Versionning.version_gem(domaine_id, currentversion, newversionid)
	  # require gems
    gems = RequiredGem.where(:domaine_id => domaine_id, :version_id => currentversion).all
    gems.each do |gem|
      new_gem = gem.dup
      new_gem.version_id = newversionid
      new_gem.save
      new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'required_gem', :obj_id => new_gem.id, :obj_current_id => gem.id, :version_id => newversionid)
      new_link_version.save
    end
  end
    
  def Versionning.version_action(domaine_id, currentversion, newversionid)
	  # action
    actions = Action.where(:domaine_id => domaine_id, :version_id => currentversion).all
    actions.each do |action|
      new_action = action.dup
      new_action.version_id = newversionid
      new_action.save
      new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'action', :obj_id => new_action.id, :obj_current_id => action.id, :version_id => newversionid)
      new_link_version.save
    end    
  end  

  def Versionning.version_element(domaine_id, projectid, currentversion, newversionid)
	  # procedure
    domelements = Domelement.select("domelements.*").joins("INNER JOIN funcandscreens on funcandscreens.domaine_id = domelements.domaine_id and funcandscreens.id = domelements.funcandscreen_id and funcandscreens.project_id in #{projectid}").where("domelements.domaine_id = #{domaine_id} and domelements.version_id = #{currentversion}").all
    domelements.each do |domelement|
      new_domelement = domelement.dup
      new_domelement.version_id = newversionid
      new_domelement.save
      new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'domelement', :obj_id => new_domelement.id, :obj_current_id => domelement.id, :version_id => newversionid)
      new_link_version.save
    end    
  end    
  
  def Versionning.version_procedure(domaine_id, projectid, currentversion, newversionid)
	  # procedure
    procedures = Procedure.select("procedures.*").joins("INNER JOIN funcandscreens on funcandscreens.domaine_id = procedures.domaine_id and funcandscreens.id = procedures.funcandscreen_id and funcandscreens.project_id in #{projectid}").where("procedures.domaine_id = #{domaine_id} and procedures.version_id = #{currentversion}").all
    procedures.each do |procedure|
      new_procedure = procedure.dup
      new_procedure.version_id = newversionid
      new_procedure.save
      new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'procedure', :obj_id => new_procedure.id, :obj_current_id => procedure.id, :version_id => newversionid)
      new_link_version.save
      procedureactions = ProcedureAction.where(:domaine_id => domaine_id, :procedure_id => procedure.id).all
      procedureactions.each do |procedureaction|
        newaction = LinkObjVersion.where(:domaine_id => domaine_id, :obj_type => 'action', :obj_current_id => procedureaction.action_id, :version_id => newversionid).first
        if newaction != nil
          newprocedureaction = procedureaction.dup
          newprocedureaction.action_id = newaction.obj_id
          newprocedureaction.procedure_id = new_procedure.id
          newprocedureaction.save
        end
      end
    end    
  end    
  
  def Versionning.version_sheet(domaine_id, projectid, currentversion, newversionid)
	  # procedure
    type_sheet = ["conception_sheet", "test_suite"]
    for i in 0..type_sheet.length-1
      sheets = Sheet.select("sheets.*").joins("INNER JOIN sheet_folders on sheet_folders.domaine_id = sheets.domaine_id and sheet_folders.id = sheets.sheet_folder_id and sheet_folders.project_id in #{projectid}").where("sheets.domaine_id = #{domaine_id} and sheets.version_id = #{currentversion} and sheets.type_sheet = \"#{type_sheet[i]}\"").all
      sheets.each do |sheet|
        new_sheet = sheet.dup
        new_sheet.version_id = newversionid
        new_sheet.save
        new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'sheet', :obj_id => new_sheet.id, :obj_current_id => sheet.id, :version_id => newversionid)
        new_link_version.save
        nodes = Node.where(:domaine_id => domaine_id, :sheet_id => sheet.id).all
        nodes.each do |node|
          new_node = node.dup
          new_node.sheet_id = new_sheet.id
          new_node.save
          new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => "node#{node.obj_type}", :obj_id => new_node.id, :obj_current_id => node.id, :version_id => newversionid)
          new_link_version.save
          node_forced_compute = NodeForcedComputer.where(:domaine_id => domaine_id, :node_id => node.id).first
          if node_forced_compute != nil
            new_node_forced_compute = node_forced_compute.dup
            new_node_forced_compute.node_id = new_node.id
            new_node_forced_compute.save
          end
          configs = NodeForcedConfig.where(:domaine_id => domaine_id, :node_id => node.id).all
          if configs != nil
            configs.each do |config|
              new_node_forced_config = config.dup
              new_node_forced_config.node_id = new_node.id
              new_node_forced_config.save
            end
          end
        end
        links = Link.where(:domaine_id => domaine_id, :sheet_id => sheet.id).all
        links.each do |link|
          new_link = link.dup
          new_link.sheet_id = new_sheet.id
          new_link.save
          new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'link', :obj_id => new_link.id, :obj_current_id => link.id, :version_id => newversionid)
          new_link_version.save
        end   
      end   
    end
    nodes = LinkObjVersion.where(:domaine_id => domaine_id, :obj_type => 'nodeconceptiontype', :version_id => newversionid).all
    nodes.each do |nodelink|
      node = Node.where(:id => nodelink.obj_id).first
      if node != nil
        new_sheet = LinkObjVersion.where(:domaine_id => domaine_id, :obj_type => 'sheet', :version_id => newversionid, :obj_current_id => node.obj_id).first
        if new_sheet != nil
          node.obj_id = new_sheet.obj_id
          node.save
        end
      end
    end
  end    
  
  
  def Versionning.version_test(domaine_id, projectid, currentversion, newversionid)
	  # procedure
    tests = Test.select("tests.*")
    .joins("INNER JOIN test_folders 
          on test_folders.domaine_id = tests.domaine_id 
          and test_folders.id = tests.test_folder_id 
          and test_folders.project_id in #{projectid}")
    .where("tests.domaine_id = #{domaine_id} 
    and tests.version_id = #{currentversion}").all
    tests.each do |test|
      new_test = test.dup
      new_test.version_id = newversionid
      sheet = LinkObjVersion.where(:domaine_id => domaine_id, :obj_type => 'sheet', :obj_current_id => test.sheet_id, :version_id => newversionid).first
      if sheet != nil 
        new_test.sheet_id = sheet.obj_id
      else
        new_test.sheet_id = nil
      end
      new_test.save
	  Node.joins("INNER JOIN sheets on sheets.id = nodes.sheet_id and type_sheet = 'test_suite' and sheets.version_id = #{newversionid}")
	  .where("nodes.domaine_id = #{domaine_id} and nodes.obj_type = 'testinsuite' and nodes.obj_id = #{new_test.current_id}")
	  .update_all(:obj_id => new_test.id)
      new_link_version = LinkObjVersion.new(:domaine_id => domaine_id, :obj_type => 'test', :obj_id => new_test.id, :obj_current_id => test.id, :version_id => newversionid)
      new_link_version.save
      teststeps = TestStep.where(:domaine_id => domaine_id, :test_id => test.id).all
      teststeps.each do |teststep|
        new_teststep = teststep.dup
        new_teststep.test_id = new_test.id
        sheet = LinkObjVersion.where(:domaine_id => domaine_id, :obj_type => 'sheet', :obj_current_id => teststep.sheet_id, :version_id => newversionid).first
        if sheet != nil 
          new_teststep.sheet_id = sheet.obj_id
        else
          new_teststep.sheet_id = nil
        end
        procedure = LinkObjVersion.where(:domaine_id => domaine_id, :obj_type => 'procedure', :obj_current_id => teststep.procedure_id, :version_id => newversionid).first
        if procedure != nil 
          new_teststep.procedure_id = procedure.obj_id
        else
          new_teststep.procedure_id = nil
        end
        new_teststep.save
      end
    end  
	teststeps = TestStep
  .joins("INNER JOIN tests on tests.domaine_id = test_steps.domaine_id and tests.id = test_id")
  .joins("INNER JOIN test_folders 
          on test_folders.domaine_id = tests.domaine_id 
          and test_folders.id = tests.test_folder_id 
          and test_folders.project_id in #{projectid}")
  .where("tests.domaine_id = #{domaine_id} and tests.version_id = #{newversionid} and test_steps.atdd_test_id is not null").all
   teststeps.each do |teststep|
		newatddtest = LinkObjVersion.where(:domaine_id => domaine_id, :obj_type => 'test', :obj_current_id => teststep.atdd_test_id, :version_id => newversionid).first
		if newatddtest != nil then TestStep.where(:atdd_test_id => teststep.atdd_test_id).update_all(:atdd_test_id => newatddtest.obj_id) end
   end
  end      
  
end
