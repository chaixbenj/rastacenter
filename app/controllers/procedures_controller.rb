class ProceduresController < ApplicationController
  before_action :require_login
  
  
  def index
    @sheet_id = (params[:sheet_id] != nil ? params[:sheet_id] : flash[:sheet_id]).to_s 
    @ext_node_id = (params[:ext_node_id] != nil ? params[:ext_node_id] : flash[:ext_node_id]).to_s 
    @fromtest = (params[:fromtest] != nil ? params[:fromtest] : flash[:fromtest]).to_s 
    @writea = (params[:writea] != nil ? params[:writea] : flash[:writea]).to_s 
    @locka = (params[:locka] != nil ? params[:locka] : flash[:locka]).to_s 
    @popup = (params[:popup] != nil ? params[:popup] : flash[:popup]).to_s 
    @atdd_param = (params[:atdd_param] != nil ? params[:atdd_param] : flash[:atdd_param]).to_s 
	@funcscreen_id = (params[:funcscreen_id] != nil ? params[:funcscreen_id] : flash[:funcscreen_id]).to_s 
	proc_search = (params[:proc_search] != nil ? params[:proc_search] : flash[:proc_search]).to_s 
    
    @procedures = nil
	
	if proc_search != "" then filtre = " and name like '%#{proc_search}%'" else filtre = "" end
	
	if @funcscreen_id != ""
		@version_id = @selectedversion
		@procedures = Procedure.where("domaine_id = #{@domaine} and funcandscreen_id = #{@funcscreen_id} and version_id = #{@version_id} #{filtre}").order("procedures.name").all
	else
		sheet = Sheet.where(:id => @sheet_id).first
		if sheet != nil
		  @version_id = sheet.version_id
		  node = Node.where(:domaine_id => sheet.domaine_id, :sheet_id => @sheet_id, :id_externe => @ext_node_id).first
		  if node != nil
			funcscreen = Funcandscreen.where(:id => node.obj_id).first
			if funcscreen != nil
			  @funcscreen_id = funcscreen.id
			  @procedures = Procedure.where("domaine_id = #{@domaine} and funcandscreen_id = #{@funcscreen_id} and version_id = #{@version_id} #{filtre}").order("procedures.name").all
			end
		  end
		end
	end
  end
  

  def incampain
    sheet_id = params[:sheet_id].to_s
    ext_node_id = params[:ext_node_id].to_s
    campain_id = params[:campain_id].to_s
    @popup = params[:popup].to_s
    run = Run.where(:domaine_id => @domaine, :campain_id => campain_id).first
    version = @selectedversion
    if run != nil then version = run.version_id   end
    @procedures = nil

    sheet = Sheet.where(:id => sheet_id).first
    if sheet != nil
      node = Node.where(:domaine_id => sheet.domaine_id, :sheet_id => sheet_id, :id_externe => ext_node_id).first
      if node != nil
        funcscreen = Funcandscreen.where(:id => node.obj_id).first
        if funcscreen != nil
          @funcname = funcscreen.name
          @procedures = Node.select("procedures.id, procedures.name, 
				count(distinct case when cmpn.cpproc_id is null then procedures.id else null end) as nboutrun,
				count(distinct case when cmpn.cpproc_id is not null and run_step_results.id is null then procedures.id else null end) as nbprocnorun,
				count(distinct case when run_step_results.id is not null and run_step_results.result like 'PASS%' then run_step_results.id else null end) as nbprocpass,
				count(distinct case when run_step_results.id is not null and run_step_results.result like 'FAIL%' then run_step_results.id else null end) as nbprocfail")
          .joins("JOIN funcandscreens on funcandscreens.domaine_id = nodes.domaine_id and funcandscreens.id = nodes.obj_id and nodes.obj_type='funcscreen'")
          .joins("JOIN procedures on procedures.domaine_id = nodes.domaine_id and procedures.funcandscreen_id = funcandscreens.id and procedures.version_id = #{version}")
          .joins("LEFT JOIN 
					(
					select case when test_steps.procedure_id is not null then test_steps.procedure_id else atdd_steps.procedure_id end as cpproc_id
					from 
					campain_test_suites 
					JOIN nodes as tests on campain_test_suites.domaine_id = tests.domaine_id and campain_test_suites.sheet_id = tests.sheet_id and tests.obj_type = 'testinsuite' 
					JOIN test_steps on test_steps.domaine_id = tests.domaine_id and test_steps.test_id = tests.obj_id
					LEFT JOIN test_steps as atdd_steps on atdd_steps.domaine_id = test_steps.domaine_id and atdd_steps.test_id = test_steps.atdd_test_id
					where campain_test_suites.domaine_id = #{@domaine} 
					and campain_test_suites.campain_id = #{campain_id}
					and campain_test_suites.domaine_id = tests.domaine_id
					and campain_test_suites.sheet_id = tests.sheet_id
					and tests.domaine_id = test_steps.domaine_id
					and tests.obj_type = 'testinsuite'
					and tests.obj_id = test_steps.test_id
					and (test_steps.procedure_id is not null or test_steps.atdd_test_id is not null)
					) 
					as cmpn on cmpn.cpproc_id = procedures.id or cmpn.cpproc_id = procedures.current_id")  
          .joins("LEFT JOIN run_step_results on run_step_results.domaine_id = nodes.domaine_id and (run_step_results.proc_id = procedures.id or run_step_results.proc_id = procedures.current_id )
			  and run_step_results.steplevel = 'procedure'
			  and run_step_results.run_id in (select id from runs where runs.domaine_id = nodes.domaine_id and runs.campain_id = #{campain_id})")
          .where("nodes.domaine_id = #{@domaine} and nodes.sheet_id = #{sheet_id} and nodes.id_externe = #{ext_node_id}")
          .all.group("procedures.id, procedures.name").order("procedures.name")



        end
      end
    end
  end
  
  def whocallaction
    action_id = params[:action_id]
    @popup = params[:popup].to_s
    @procedures = nil
    if action_id !=nil
      @action = Action.where(:id => action_id).first
      @actions = Action.where(:domaine_id => @domaine, :version_id => @action.version_id, :callable_in_proc => 1).all
      if @action != nil and params[:replacingaction].to_s != "" and params[:proclist].to_s != ""
        #remplacement d'une action par une autre
        rempaction = Action.where(:id => params[:replacingaction]).first
        if rempaction != nil
          procs = params[:proclist].to_s.split("||")
          procs.each do |proc|
            procedure = Procedure.where(:id => proc.gsub("|","").to_i).first
            if procedure != nil
              procedure.code = procedure.code.gsub("action.#{@action.name}(", "action.#{rempaction.name}(")
              procedure.save
			  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{procedure.funcandscreen_id}", :version_id => @action.version_id, :get => 0).update_all(:get => 1)
              ProcedureAction.where(:procedure_id => procedure.id, :action_id => @action.id).update_all(:action_id => rempaction.id)
              @action.nb_used = [0, @action.nb_used-1].max
              rempaction.nb_used = rempaction.nb_used.to_i + 1
              @action.save
              rempaction.save
            end
          end
        end
      end
      @procedures = ProcedureAction
      .select("projects.name as projectname, funcandscreens.name as funcname, roles.droits as droit, procedures.*")
      .joins("INNER JOIN procedures on procedures.id = procedure_actions.procedure_id")
      .joins("INNER JOIN funcandscreens on funcandscreens.id = procedures.funcandscreen_id")
      .joins("INNER JOIN projects on projects.id = funcandscreens.project_id")
      .joins("INNER JOIN userprojects on userprojects.project_id = projects.id and user_id=#{@my_user_id}")
      .joins("INNER JOIN roles on roles.id = userprojects.role_id").where(:action_id => action_id).all
    end
  end

  
  def create
    @funcandscreen_id = params["funcandscreen_id"]
    @popup = params[:popup].to_s
    @version_id = params["version_id"]
    if params[:pasteadd] == "add"
      name = params["name"]
      description = params["description"]
      @procedure = Procedure.new
      @procedure.domaine_id = @domaine
      @procedure.name = name
      @procedure.description = description
      @procedure.funcandscreen_id = @funcandscreen_id
      @procedure.version_id = @version_id
      @procedure.save
      @procedure.current_id = @procedure.id
    else
      if params[:pasteadd] == "paste" and cookies[:procedure_copy_id].to_s != ""
		proc_init = Procedure.where(:id => cookies[:procedure_copy_id]).first
		if proc_init != nil
			procedure_copy_name = cookies[:procedure_copy_name].to_s
			procedure_copy_description = proc_init.description.to_s
			procedure_copy_parameters = proc_init.parameters.to_s
			procedure_copy_init_funcandscreen = proc_init.funcandscreen_id.to_s
			procedure_copy_code = proc_init.code.to_s
		else
			procedure_copy_name = cookies[:procedure_copy_name].to_s
			procedure_copy_description = cookies[:procedure_copy_description].to_s
			procedure_copy_parameters = cookies[:procedure_copy_parameters].to_s
			procedure_copy_init_funcandscreen = cookies[:procedure_copy_init_funcandscreen].to_s
			procedure_copy_code = cookies[:procedure_copy_code].to_s
		end
        @procedure = Procedure.new
        @procedure.domaine_id = @domaine
        @procedure.name = procedure_copy_name
        @procedure.description = procedure_copy_description
        @procedure.parameters = procedure_copy_parameters
        @procedure.version_id = @version_id
        @procedure.funcandscreen_id = @funcandscreen_id
        @procedure.save
        procedureactions = ProcedureAction.where(:domaine_id => @domaine, :procedure_id => cookies[:procedure_copy_id]).all
        procedureactions.each do |procedureaction|
          newprocedureaction = procedureaction.dup
          newprocedureaction.procedure_id = @procedure.id
          newprocedureaction.save
          action = Action.where(:id => procedureaction.action_id).first
          if action != nil
            action.nb_used += 1
            action.save
          end
        end
        @procedure.current_id = @procedure.id
        if procedure_copy_init_funcandscreen == @funcandscreen_id
          @procedure.code = procedure_copy_code
          if procedure_copy_code.to_s.index("$domelement") != nil
            initdomelements = Domelement.where(:domaine_id => @domaine, :version_id => @selectedversion, :funcandscreen_id => procedure_copy_init_funcandscreen).all
            initdomelements.each do |initdomelement|
              if procedure_copy_code.to_s.index("$domelement#{initdomelement.current_id}_") != nil
                initdomelement.is_used +=1
                initdomelement.save
              end
            end
          end
        else
          code = procedure_copy_code.to_s
          if code.index("$domelement") != nil
            initdomelements = Domelement.where(:domaine_id => @domaine, :funcandscreen_id => procedure_copy_init_funcandscreen, :version_id => @selectedversion).all
            initdomelements.each do |initdomelement|
              if code.index("$domelement#{initdomelement.current_id}_") != nil
                newdomelement = Domelement.where(:domaine_id => @domaine, :version_id => @selectedversion, :funcandscreen_id => @funcandscreen_id, :name => initdomelement.name).first
                if newdomelement != nil
                  code = code.gsub("$domelement#{initdomelement.current_id}_", "$domelement#{newdomelement.current_id}_")
                  newdomelement.is_used += 1
                  newdomelement.save
                else
                  newdomelement = Domelement.where(:domaine_id => @domaine, :version_id => @selectedversion, :funcandscreen_id => @funcandscreen_id, :name => initdomelement.name + "_copy").first
                  if newdomelement != nil
                    code = code.gsub("$domelement#{initdomelement.current_id}_", "$domelement#{newdomelement.current_id}_")
                    newdomelement.is_used += 1
                    newdomelement.save
                  else
                    newdomelement = Domelement.new
                    newdomelement.domaine_id = @domaine
                    newdomelement.name = initdomelement.name + "_copy"
                    newdomelement.funcandscreen_id = @funcandscreen_id
                    newdomelement.version_id = @version_id
                    newdomelement.description = initdomelement.description
                    newdomelement.strategie = initdomelement.strategie
                    newdomelement.path = initdomelement.path
                    newdomelement.is_used = 1
                    newdomelement.save
                    newdomelement.current_id = newdomelement.id
                    newdomelement.save
                    code = code.gsub("$domelement#{initdomelement.current_id}_", "$domelement#{newdomelement.current_id}_")
                  end
                end
              end
            end
          end  
          @procedure.code = code
        end
        cookies.delete(:procedure_copy_name)
        cookies.delete(:procedure_copy_id)
        cookies.delete(:procedure_copy_description)
        cookies.delete(:procedure_copy_parameters)
        cookies.delete(:procedure_copy_code)
        cookies.delete(:procedure_copy_init_funcandscreen)
      end
    end
    respond_to do |format|
      if @procedure.save
        ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{@procedure.funcandscreen_id}", :version_id => @procedure.version_id, :get => 0).update_all(:get => 1)
        @procedures = Procedure.where(:domaine_id => @domaine, :funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("name").all
        format.html { redirect_to @procedure, notice: 'procedure was successfully created.' }
        format.js   {}
        format.json { render json: @procedure, status: :created, location: @procedure }
      else
        @procedures = Procedure.where(:domaine_id => @domaine, :funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("name").all
        format.html { render action: "new" }
        format.json { render json: @procedure.errors, status: :unprocessable_entity }
      end
    end

  end


  def destroy
    @popup = params[:popup].to_s
    @funcandscreen_id = params["funcandscreen_id"]
    @version_id = params["version_id"]
		@procedure = Procedure.where(:id => params[:id]).first
    if @procedure != nil
      @funcandscreen_id = @procedure.funcandscreen_id
      @version_id = @procedure.version_id

      @domelements = Domelement.where(:domaine_id => @domaine, :version_id => @selectedversion, :funcandscreen_id => @procedure.funcandscreen_id).all
      initialCode = @procedure.code.to_s
      @domelements.each do |element|
        if element.is_used == nil
          element.is_used = 0
          element.save
        end
        if initialCode.index("$domelement#{element.current_id}_") != nil
          element.is_used = [0 , element.is_used.to_i-1].max
          element.save
        end
      end 
      
      procedureactions = ProcedureAction.where(:procedure_id => @procedure.id).all
      procedureactions.each do |procedureaction|
        action = Action.where(:id => procedureaction.action_id).first
        if action != nil
          action.nb_used = [0 , action.nb_used.to_i-1].max
          action.save
        end
        procedureaction.destroy
      end
      
      ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{@procedure.funcandscreen_id}", :version_id => @procedure.version_id, :get => 0).update_all(:get => 1)
      @procedure.destroy
    end
		@procedures = Procedure.where(:domaine_id => @domaine, :funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("procedures.name").all
  end
  
  def update
    @popup = params[:popup].to_s
    idelement = params["idelement"]
    @majid = idelement
    name = params["name"]
    description = params["description"]
    @funcandscreen_id = params["funcandscreen_id"]
    @version_id = params["version_id"]
    
    @procedure = Procedure.where(:id => idelement).first
    if @procedure != nil
      @funcandscreen_id = @procedure.funcandscreen_id
      @version_id = @procedure.version_id
      @procedure.name = name
      @procedure.description = description
      @procedure.save
      ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{@procedure.funcandscreen_id}", :version_id => @procedure.version_id, :get => 0).update_all(:get => 1)
      @procedures = Procedure.where(:domaine_id => @domaine, :funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("procedures.name").all
      @message, @OK = Commun.set_message("1")
    else
      @procedures = Procedure.where(:domaine_id => @domaine, :funcandscreen_id => @funcandscreen_id, :version_id => @version_id).order("procedures.name").all
      @message, @OK = Commun.set_message("9")
    end
    #	system('pause')
  end  



  def edit
    procedure_id = (params[:procedure_id] != nil ? params[:procedure_id] : flash[:procedure_id]).to_s
    @popup = (params[:popup] != nil ? params[:popup] : flash[:popup]).to_s
    if TestStep.where(:domaine_id => @domaine, :procedure_id => procedure_id).first != nil then @iscalled = true else @iscalled = false end
    

    @procedure = Procedure.where(:id => procedure_id).first
    @actions = nil
    @domelements = nil
	
    @configurationvariables, @environnementvariables, @data_set_variables, @testconstantes = Commun.get_variables_and_constantes_names(@domaine, @selectedversion)
	
	
    if @procedure != nil
	  
		  
      @actions = Action.where(:domaine_id => @domaine, :version_id => @procedure.version_id, :callable_in_proc => 1).order("name").all
      @domelements = Domelement.where(:domaine_id => @domaine, :version_id => @selectedversion, :funcandscreen_id => @procedure.funcandscreen_id).order(:name).all
      
      if params[:procedure_parameters] != nil
        initialparameters = @procedure.parameters
        @procedure.parameters = params[:procedure_parameters].to_s[0..1023]
        @procedure.return_values = params[:procedure_parameters_out].to_s.to_s[0..1023]
        
        #code
        initialCode = @procedure.code.to_s
        @code = params[:procedure_code].to_s
        code = @code
        reversecountelement = Array.new
        @domelements.each do |element|
          if element.is_used == nil
            element.is_used = 0
            element.save
          end
          if initialCode.index("$domelement#{element.current_id}_") != nil
            element.is_used = [0 , element.is_used-1].max
            element.save
            reversecountelement << [element.id, 1]
          end
          if code.index("[#{element.name}]") != nil
            element.is_used += 1
            element.save
            reversecountelement << [element.id, -1]
          end
          code = code.gsub("[#{element.name}]", "$domelement#{element.current_id}_")
        end 
        
        
        if code.has_valid_syntax
        
          @procedure.code = code
		
          #actions
          wcode = code
          procedureactions = ProcedureAction.where(:domaine_id => @domaine, :procedure_id => @procedure.id).all
          procedureactions.each do |procedureaction|
            action = Action.where(:id => procedureaction.id).first
            if action != nil
              action.nb_used = [0, action.nb_used.to_i-1].max
              action.save
            end
            procedureaction.destroy
          end
          if wcode.index("$action.") != nil
            begin
              wcode = wcode[wcode.index("$action.")+7..wcode.length]
              actionname = wcode[wcode.index(".")+1..wcode.index("(")-1]
              action = Action.where(:domaine_id => @domaine, :name => actionname).first
              if action != nil
                procedureaction = ProcedureAction.where(:procedure_id => @procedure.id, :action_id => action.id).first
                if procedureaction == nil
                  action.nb_used = action.nb_used.to_i + 1
                  action.save
                  procedureaction = ProcedureAction.new
                  procedureaction.domaine_id = @domaine
                  procedureaction.procedure_id = @procedure.id
                  procedureaction.action_id = action.id
                  procedureaction.save
                end
              end
            end while wcode.index("$action.") != nil
          end
		
          @procedure.save
		  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{@procedure.funcandscreen_id}", :version_id => @procedure.version_id, :get => 0).update_all(:get => 1)
          @message, @OK = Commun.set_message("1")
		  
          if initialparameters.to_s != @procedure.parameters.to_s and @iscalled == true
            initparams = initialparameters.to_s.split('|$|')
            initparam = []
			
            for i in 0..(initparams.length-1)
              if i%2 == 0 then initparam << initparams[i] end
            end

            newparams = @procedure.parameters.to_s.split('|$|')
            newparam = []
            for i in 0..(newparams.length-1)
              if i%2 == 0 then newparam << newparams[i] end
            end

            if newparam.to_s != initparam.to_s
              conversion = []
              transco_ok = 0
              for i in 0..initparam.length-1
                foundinit = false
                for j in 0..newparam.length-1
                  if initparam[i] == newparam[j]
                    conversion[i] = j
                    transco_ok += 1
                    foundinit = true
                    break
                  end
                end
                if foundinit == false
                  foundnew = false
                  if newparam.length >= i-1
                    for k in 0..initparam.length-1
                      if newparam[i] == initparam[k]
                        foundnew = true
                        break
                      end
                    end
                  end
                  if foundnew == false and newparam.length >= i+1
                    conversion[i] = i
                    transco_ok += 1
                  else 
                    conversion[i] = nil
                  end
                end
              end

              if transco_ok < newparam.length
                for i in transco_ok..newparam.length-1
                  conversion << -1
                end
              end	
              teststeps = TestStep.where(:domaine_id => @domaine, :procedure_id => @procedure.id).all
              teststeps.each do |teststep|
                stepparam = teststep.parameters.to_s.split('|$|')
                newparam = []
                for i in 0..conversion.length-1
                  if conversion[i] != nil and conversion[i] >= 0
                    newparam[conversion[i]] = stepparam[i] 
                  else 
                    if conversion[i] != nil then newparam << "" end
                  end
                end
                teststep.parameters = newparam.join('|$|') + '|$|'
                teststep.save
				ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{teststep.test_id}", :version_id => @procedure.version_id, :get => 0).update_all(:get => 1)
              end
            end
          end

          
          @OK=true
        
        else
          reversecountelement.each do |rvel|
            if rvel != nil
              element = Domelement.where(:id => rvel[0]).first
              if element != nil
                element.is_used += rvel[1]
                element.save
              end
            end
          end
          cookies[:badproccode] = params[:procedure_code].to_s
          @message = code.syntax_errors
          @badcode = true
          @OK=false
        end
      else
        @code = @procedure.code
        if @code != nil and @code.index("$domelement") != nil
          @domelements.each do |element|
            @code = @code.gsub("$domelement#{element.current_id}_", "[#{element.name}]")
          end
        end
      end
      
    end
  end






  def listtoaddtotest
    @atdd_param = params[:atdd_param].to_s
    @sheet_id = params[:sheet_id].to_s
    @ext_node_id = params[:ext_node_id].to_s
    @modemodif = params[:write].to_s
    @testLocked = params[:lock].to_s
    @popup = params[:popup].to_s
    @procedures = nil
    @configurationvariables = ConfigurationVariable.where(:domaine_id => @domaine).all
    @environnementvariables = EnvironnementVariable.select("distinct varinit.*")
    .joins("INNER JOIN environnements on environnements.domaine_id = environnement_variables.domaine_id and environnements.id = environnement_variables.environnement_id")
    .joins("INNER JOIN environnement_variables as varinit on environnements.domaine_id = varinit.domaine_id and environnement_variables.init_variable_id = varinit.id")
    .where("environnements.domaine_id = #{@domaine} and environnements.version_id = #{@selectedversion} and varinit.project_id = #{@selectedproject}").order("varinit.name").all
    @data_set_variables = DataSetVariable.select("distinct varinit.*")
    .joins("INNER JOIN data_sets on data_sets.domaine_id = data_set_variables.domaine_id and data_sets.id = data_set_variables.data_set_id")
    .joins("INNER JOIN data_set_variables as varinit on data_sets.domaine_id = varinit.domaine_id and data_set_variables.init_variable_id = varinit.id  and varinit.project_id = #{@selectedproject}")
    .where("data_sets.domaine_id = #{@domaine} and data_sets.version_id = #{@selectedversion}").order("varinit.name").all
    @testconstantes = TestConstante.where(:domaine_id => @domaine, :project_id => @selectedproject).order(:name).all
    
    sheet = Sheet.where(:id => @sheet_id).first
    if sheet != nil
      node = Node.where(:domaine_id => sheet.domaine_id, :sheet_id => @sheet_id, :id_externe => @ext_node_id).first
      if node != nil
        funcscreen = Funcandscreen.where(:id => node.obj_id).first
        @nodes_after = Node
        .select("nodes.*")
        .joins("INNER JOIN links on nodes.domaine_id = links.domaine_id and links.sheet_id = nodes.sheet_id and links.node_son_id_fk = nodes.id_externe")
        .where("nodes.domaine_id = #{sheet.domaine_id} and nodes.sheet_id = #{@sheet_id} and links.node_father_id_fk = #{node.id_externe}")
        .all.order("nodes.name")
        @nodes_before = Node.select("nodes.*")
        .joins("INNER JOIN links on nodes.domaine_id = links.domaine_id and links.sheet_id = nodes.sheet_id and links.node_father_id_fk = nodes.id_externe")
        .where("nodes.domaine_id = #{sheet.domaine_id} and nodes.sheet_id = #{@sheet_id} and links.node_son_id_fk = #{node.id_externe}")
        .all.order("nodes.name")
        if funcscreen != nil
          @funcscreen_id = funcscreen.id
          @func_name = funcscreen.name
          @version_id = sheet.version_id
          @node_id = node.id_externe
          @procedures = Procedure.where(:domaine_id => @domaine, :funcandscreen_id => @funcscreen_id, :version_id => @version_id).order("procedures.name").all
        end
      end
    end

    
  end

  def copy
    if params[:procedure_id] != nil
      @procedure = Procedure.where(:id => params[:procedure_id]).first
      if @procedure != nil
        cookies[:procedure_copy_name] = @procedure.name.to_s + "_copy"
        cookies[:procedure_copy_id] = @procedure.id
        cookies[:procedure_copy_description] = @procedure.description.to_s
        cookies[:procedure_copy_parameters] = @procedure.parameters.to_s
        cookies[:procedure_copy_code] = @procedure.code.to_s
        cookies[:procedure_copy_init_funcandscreen] = @procedure.funcandscreen_id
        render html: 'ok', status: '200'
      end
    end
  end

  
end