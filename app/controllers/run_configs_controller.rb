class RunConfigsController < ApplicationController
  before_action :require_login

  
  def testindex
    @type = params[:type].to_s
    @elem_id = params[:elem_id].to_s
    @popup = params[:popup].to_s
    @run_id = params[:run].to_s
	initrun_id = params[:initrun].to_s
    @message, @OK = Commun.set_message(params[:kop])
    
    @computers = Computer.where("domaine_id = #{@domaine}").order(:hostrequest).all
    @default_computer = User.where(:id => @my_user_id).first.preferences.to_s.split('|')[0].to_s
	
    if @type == 'test'
      @test = Test.where(:id => @elem_id).first
      if @test != nil
        test_type = ListeValue.where(:domaine_id => @domaine, :id => @test.test_type_id).first
        if test_type != nil
          @test_type = test_type.value
        end
      end
    end

    if @type == 'suite'
      @sheet = Sheet.where(:id => @elem_id).first
    end
    
    if @run_id == "" and initrun_id == ""
      @default_user_configs = 
        ConfigurationVariable.select("configuration_variables.id as variable_id, 
                           configuration_variables.name as variable_name, 
                           configuration_variable_values.value as allowed_value, 
                           default_user_configs.id as user_configs_id, 
                           default_user_configs.variable_value as user_variable_value")
      .joins("INNER JOIN configuration_variable_values 
                            on configuration_variable_values.domaine_id=configuration_variables.domaine_id and configuration_variable_values.configuration_variable_id=configuration_variables.id 
                          LEFT OUTER JOIN default_user_configs 
                            on default_user_configs.domaine_id = configuration_variables.domaine_id and default_user_configs.user_id = #{@my_user_id} and default_user_configs.variable_id = configuration_variables.id
        ")
      .where("configuration_variables.domaine_id = #{@domaine}").all.order("configuration_variables.name, configuration_variable_values.value")
    else
	  if initrun_id == "" then run_id = @run_id else run_id = initrun_id end
      @default_user_configs = 
        ConfigurationVariable.select("configuration_variables.id as variable_id, 
                           configuration_variables.name as variable_name, 
                           configuration_variable_values.value as allowed_value, 
                           run_configs.id as user_configs_id, 
                           run_configs.variable_value as user_variable_value")
      .joins("INNER JOIN configuration_variable_values 
                            on configuration_variable_values.configuration_variable_id=configuration_variables.id 
                          LEFT OUTER JOIN run_configs 
                            on run_configs.run_id = #{run_id} and run_configs.variable_id = configuration_variables.id
        ")
      .where("configuration_variables.domaine_id = #{@domaine}").all.order("configuration_variables.name, configuration_variable_values.value")
    end
	@campain_id = nil
	if initrun_id != ""
		run = Run.where(:id => initrun_id).first
		if run != nil then @campain_id = run.campain_id end
	end
		
  end  

  def testupdate
    kop = 99
    testtype = params[:type].to_s
    elem_id = params[:elem_id].to_s
    popup = params[:popup].to_s 
    run_id = params[:run].to_s
    computer = params[:computer].to_s
	campain_id = params[:campain_id].to_s
	
	suite_name = ""
    if testtype.start_with? 'test'
      elem = Test.where(:id => elem_id).first
      typetest = ListeValue.where(:id => elem.test_type_id).first
      runtype = typetest.value
      test_id = elem.id
      version_id = elem.version_id
      suite_id = nil
	  project_id = TestFolder.where(:id => elem.test_folder_id).first.project_id
	  name = elem.name
	  private = elem.private
	  nbtest = 1
    end
    if testtype.start_with? 'suite'
      elem = Sheet.where(:id => elem_id).first
	  suite_name = elem.name
      runtype = 'suite'
      test_id = nil
      suite_id = elem.id
      version_id = elem.version_id
	  project_id = SheetFolder.where(:id => elem.sheet_folder_id).first.project_id
	  name = elem.name
	  private = elem.private
	  nbtest = Node.select("count(1) as nbtest").where(:domaine_id => @domaine, :sheet_id => elem.id).first.nbtest.to_s.to_i - 1
    end

    if elem != nil
      #créer un run avec ou sans campagne
      if run_id == "" or Run.where(:id => run_id).first == nil
        run = Run.where("domaine_id=#{@domaine} and hostrequest='#{computer}' and campain_id is null and status = 'startable'").first
        if run then run.destroy end
        run = Run.new
		if campain_id != nil and Campain.where(:id => campain_id).first != nil then
			campain = Campain.where(:id => campain_id).first
			cycle = Cycle.where(:id => campain.cycle_id).first
			release = Release.where(:id => cycle.release_id).first
			project = Project.where(:id => release.project_id).first
			run.campain_id = campain_id 
			run.name = "#{name}|#{project.name} / #{release.name} / #{cycle.name} / #{campain.name}"[0..499]
		else 
			run.name = name
		end
        run.domaine_id = @domaine
        run.user_id = @my_user_id
        run.run_type = runtype
        run.test_id = test_id
        run.suite_id = suite_id
        run.version_id = version_id
		run.project_id = project_id
		run.private = private
		run.nbtest = nbtest
		run.nbtestpass = 0
		run.nbtestfail = 0
		run.nbprocfail = 0
        run.hostrequest = computer
		run.status = 'startable'
		run.exec_code = "#testclassrequire\n"
		run.conf_string = ""
        run.save
        run_id = run.id
		variables = ConfigurationVariable.where(:domaine_id => @domaine).all
		  variables.each do |variable|
			if params["varvalue#{variable.id}"] != nil
			  run_config = RunConfig.new
			  run_config.domaine_id = @domaine
			  run_config.run_id = run_id
			  run_config.variable_id = variable.id
			  run_config.variable_value = params["varvalue#{variable.id}"].to_s
			  run_config.save
			end
		  end
		if suite_id != nil
			Commun.build_sub_run(@domaine, suite_id, run.id, suite_name)
			Commun.saverunsuiteschemes(run)
		else
			run.exec_code += "$currenttestnodeid = 0\ntest#{test_id}=Test#{test_id}.new\ntest#{test_id}.execute\n$report.log('endrun')\n"
			requirestr = "require_relative \"../Test#{test_id}.rb\"\n"
			if run.exec_code.index(requirestr) == nil then run.exec_code = run.exec_code.sub("#testclassrequire\n","#testclassrequire\n" + requirestr) end
			run.save
		    Commun.set_run_string_config(@domaine, run.id, 0, -1, "")
		end
        
      else
        run = Run.where(:id => run_id).first
        run.status = 'startable'
        run.save
		variables = ConfigurationVariable.where(:domaine_id => @domaine).all
		  variables.each do |variable|
			if params["varvalue#{variable.id}"] != nil
			  run_config = RunConfig.new
			  run_config.domaine_id = @domaine
			  run_config.run_id = run_id
			  run_config.variable_id = variable.id
			  run_config.variable_value = params["varvalue#{variable.id}"].to_s
			  run_config.save
			end
		  end
      end
      
      kop = 11

    end    
    redirect_to controller: 'run_configs', action: 'testindex', type: testtype, elem_id: elem_id, kop: kop, popup: popup, run: run_id
  end
  
  

  

  
  
end
