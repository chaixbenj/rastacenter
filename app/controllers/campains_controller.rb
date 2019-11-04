class CampainsController < ApplicationController
  before_action :require_login
  skip_before_action :require_login, only: [:wslaunch, :wscampainresults]
  skip_before_action :verify_authenticity_token, only: [:wslaunch, :wscampainresults]
  
  def index
    release_id = (params[:release_id] != nil ? params[:release_id] : flash[:release_id]).to_s
    cycle_id = (params[:cycle_id] != nil ? params[:cycle_id] : flash[:cycle_id]).to_s
    campain_id = (params[:campain_id] != nil ? params[:campain_id] : flash[:campain_id]).to_s
    show = (params[:show] != nil ? params[:show] : (flash[:show] != nil ? flash[:show] : "detail")).to_s

    @releasecyclecampains = Project.select("projects.id as project_id, 
	projects.name as project_name, 
	releases.id as release_id, 
	releases.name as release_name, 
	cycles.id as cycle_id, 
	cycles.name as cycle_name, 
	campains.id as campain_id, 
	campains.name as campain_name, 
	campains.private as campain_private")
		.joins("INNER JOIN userprojects on userprojects.domaine_id = projects.domaine_id and userprojects.project_id = projects.id      
	LEFT OUTER JOIN releases on  releases.domaine_id = projects.domaine_id and releases.project_id = projects.id      
	LEFT OUTER JOIN cycles on  cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id      
	LEFT OUTER JOIN campains on  campains.domaine_id = cycles.domaine_id and campains.cycle_id = cycles.id and (campains.private = 0 or campains.owner_user_id = #{@my_user_id})")
		.where("projects.domaine_id = #{@domaine} and userprojects.user_id = #{@my_user_id}" )
		.order("projects.id, releases.id, cycles.id, campains.id").all
	 
		
	case show
		when "detail"
		@message, @OK = Commun.set_message(params[:kop])
  	    if release_id != "" then @release = Release.where(:id => release_id).first end
		if cycle_id != "" then @cycle = Cycle.where(:id => cycle_id).first end
		if campain_id != ""
        @campain = Campain.where(:id => campain_id).first
        @campain_id = campain_id
        @campain_configs = 
          ConfigurationVariable.select("configuration_variables.id as variable_id, 
							   configuration_variables.name as variable_name, 
							   configuration_variable_values.value as allowed_value, 
							   campain_configs.id as user_configs_id, 
							   campain_configs.variable_value as user_variable_value")
        .joins("INNER JOIN configuration_variable_values 
								on configuration_variable_values.configuration_variable_id=configuration_variables.id 
							  LEFT OUTER JOIN campain_configs 
								on campain_configs.campain_id = #{@campain.id} and campain_configs.variable_id = configuration_variables.id")
        .where("configuration_variables.domaine_id = #{@domaine}").all.order("configuration_variables.name, configuration_variable_values.value")
  	    end
		when "launch"
		  @campain_id = params[:campain_id].to_s
		  if @campain_id != ''
				releasecyclecampain = Campain.select(" 
			projects.name as pname,
			releases.name as rname,
			cycles.name as clname,
			campains.name as cpname")
				.joins("INNER JOIN cycles on cycles.id = campains.cycle_id    
			INNER JOIN releases on  cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id      
			INNER JOIN projects on projects.id = releases.project_id")
				.where("campains.id = #{@campain_id}").first
				if releasecyclecampain != nil
				  @releasecyclecampainname = releasecyclecampain.pname + " / " + releasecyclecampain.rname + " / " + releasecyclecampain.clname + " / " + releasecyclecampain.cpname
				end
				@computers = Computer.where("domaine_id = #{@domaine}").order(:hostrequest).all
				@default_computer = User.where(:id => @my_user_id).first.preferences.to_s.split('|')[0].to_s
				@campainsteps = CampainTestSuite
				.select("campain_test_suites.*, sheets.name as name, sheets.private as sheet_private, sheets.owner_user_id as sheet_owner_user_id")
				.joins("INNER JOIN sheets on sheets.current_id = sheet_id and version_id =#{@selectedversion}")
				.where(:domaine_id => @domaine, :campain_id => @campain_id).all.order(:sequence)
		  end 
		else
		end  
		@displayedelements = cookies[:releasedisplayed]
  end    
  
  def new
    if params[:cycle_id] != nil 
      cycle = Cycle.where(:id => params[:cycle_id]).first 
      if cycle != nil
        campain = Campain.new
        campain.name =  t('ecr_campain.nouvelle_campagne')
        campain.domaine_id = @domaine
        campain.cycle_id = params[:cycle_id]
        if @can_manage_public_campain == 1
          campain.private = 0
        else
          campain.private = 1
        end
        campain.owner_user_id = @my_user_id
        campain.save
        default_user_configs = DefaultUserConfig.where(:domaine => @domaine, :user_id => @my_user_id).all
        default_user_configs.each do |user_config|
          campainconfig = CampainConfig.new(:domaine_id => @domaine, :campain_id => campain.id, :variable_id => user_config.variable_id, :variable_value => user_config.variable_value)
          campainconfig.save
        end
        flash[:campain_id] = campain.id
        flash[:show] = 'detail'
        redirect_to controller: 'campains', action: 'index'
      end
    end
  end  

  def update
    kop = 99
    campain_id = params[:elem_id]
    campain = Campain.where(:id => campain_id).first
    if campain != nil
      if (@can_manage_public_campain == 1 and campain.private == 0) or campain.owner_user_id == @my_user_id

        if params[:delete] != nil
          #CampainConfig.where(:domaine_id => @domaine, :campain_id => campain.id).delete_all
          campain.destroy
          #TODO : supprimer tous les objets associés
          kop = 1
        end

        if params[:valid] != nil
          campain.name = params[:pname].to_s
          campain.description = params[:pdesc].to_s
          if params[:private].to_s  == ""
            campain.private = 0
          else
            campain.private = 1
          end
          campain.save
          kop = 1
          
          variables = ConfigurationVariable.where(:domaine_id => @domaine).all
          variables.each do |variable|
            if params["varvalue#{variable.id}"] != nil
              campain_config = CampainConfig.where(:domaine_id => @domaine, :campain_id => campain.id, :variable_id => variable.id).first
              if campain_config != nil
                campain_config.variable_value = params["varvalue#{variable.id}"].to_s
                campain_config.save
              else
                campain_config = CampainConfig.new
                campain_config.domaine_id = @domaine
                campain_config.campain_id = campain.id
                campain_config.variable_id = variable.id
                campain_config.variable_value = params["varvalue#{variable.id}"].to_s
                campain_config.save
              end
            end
          end
          flash[:show] = 'detail'
          flash[:campain_id] = campain.id  
        end
      end
    end
    flash[:kop] = kop
    redirect_to controller: 'campains', action: 'index'
  end
  
  
  
  def edit
    campain_id = (params[:campain_id] != nil ? params[:campain_id] : flash[:campain_id]).to_s
    @modmodif = (params[:write] != nil ? params[:write] : flash[:write]).to_s
    @mode = (params[:mode] != nil ? params[:mode] : flash[:mode]).to_s
		@sname = (params[:snames] != nil ? params[:snames] : flash[:snames]).to_s

    if campain_id != "" then @campain = Campain.where(:id => campain_id).first end
    if @campain == nil
      flash[:kop] = 1
      redirect_to controller: 'campains', action: 'index'
    else
      
      #pose du lock
      if @campain != nil 
        if ((@can_manage_public_campain == 1 and @campain.private == 0) or @campain.owner_user_id == @my_user_id) and @modmodif != "0"
          is_locked = Lockobject.where("domaine_id = #{@domaine} and obj_id = #{@campain.id} and obj_type = 'campain' and user_id != #{@my_user_id}").first
          if is_locked != nil and (Time.now - is_locked.created_at)/3600 < 2
            @campainLocked = true
            @lockBy = User.where(:id => is_locked.user_id).first.username
          else
            @campainLocked = false
            Lockobject.where("obj_id = #{@campain.id} and obj_type = 'campain'").delete_all
            newlock = Lockobject.new
            newlock.domaine_id = @domaine
            newlock.obj_id = @campain.id
            newlock.obj_type = 'campain'
            newlock.user_id = @my_user_id
            newlock.save
          end
        else
          @campainLocked = true
          @lockBy = nil
        end
      end  
      
      
      
      @testLocked = false
      @campainsteps = CampainTestSuite
      .select("campain_test_suites.*, sheets.id as versionned_sheet_id, sheets.name as name, sheets.private as sheet_private, sheets.owner_user_id as sheet_owner_user_id")
      .joins("INNER JOIN sheets on sheets.current_id = sheet_id and version_id =#{@selectedversion}")
      .where(:domaine_id => @domaine, :campain_id => campain_id).all.order(:sequence)
      
      if @mode == nil or @mode == "" or @mode == "folder"
        root_sheet_folder = SheetFolder.where(:domaine_id => @domaine, :sheet_folder_father_id => nil).first
        @cpt = 0
        @htmlrepertoire = ""
        lister_folder(root_sheet_folder, "divrep-0", 0, 'test_suite')
        @htmlrepertoire = @htmlrepertoire.html_safe
      else
        if @sname != ""
          sheets = Sheet.select("sheets.*")
          .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id ")
          .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id")
          .where("userprojects.user_id=#{@my_user_id} and sheets.name like '%#{@sname}%' and sheets.type_sheet='test_suite' and sheets.version_id =#{@selectedversion} and (private=0 or owner_user_id = #{@my_user_id})")
          .order(:name).all
        else  
          sheets = Sheet.select("sheets.*")
          .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
          .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id")
          .where("userprojects.user_id=#{@my_user_id} and sheets.type_sheet='test_suite' and sheets.version_id =#{@selectedversion} and (private=0 or  owner_user_id = #{@my_user_id})").order(:name).all
        end
        @htmlliste = ""
        sheets.each do |sheet|
          if @can_manage_public_campain == 0 and sheet.owner_user_id != @my_user_id
            @htmlliste += "<div style='display: block;'><div class='treegroup' id='sheet#{sheet.id}'><input type='hidden' id='hidoltn#{sheet.id}' value='#{sheet.name.gsub("'","&apos;")}'/><div class='ligthline' ><div class='treeline' id='spant#{sheet.id}' ><span>#{sheet.name}</span></div></div></div></div>"
          else
            @htmlliste += "<div style='display: block;'><div class='treegroup' id='test#{sheet.id}'><input type='hidden' id='hidoltn#{sheet.id}' value='#{sheet.name.gsub("'","&apos;")}'/><div class='ligthline' ><div class='treeline' id='spant#{sheet.id}' ><span>#{sheet.name}</span></div><button class='btnadd' title='#{t('ajouter')}' style='float: right;' onclick='addcampainstep(#{sheet.id});'></button></div></div></div>"
          end  
        end
        @htmlliste = @htmlliste.html_safe  
    
      end
    end
  end
    
  
  
  
  def paste
    kop = 99
    cycle_id = params[:cycle_id]
    campain_id = params[:campain_id]
    cookies[:campain_to_paste] = ""
  
    if cycle_id != nil and campain_id != nil
      cycle = Cycle.where(:domaine_id => @domaine, :id => cycle_id).first
      campain = Campain.where(:id => campain_id).first
      if cycle != nil and campain != nil
        newcampain = campain.dup
        newcampain.cycle_id = cycle.id
        newcampain.owner_user_id = @my_user_id
        newcampain.name += "_copy"
        newcampain.save
        campainconfigs = CampainConfig.where(:domaine_id => @domaine, :campain_id => campain_id).all
        campainconfigs.each do |campainconfig|
          newcampainconfig = campainconfig.dup
          newcampainconfig.campain_id = newcampain.id
          newcampainconfig.save
        end
        campaintestsuites = CampainTestSuite.where(:domaine_id => @domaine, :campain_id => campain_id).all
        campaintestsuites.each do |campaintestsuite|
          newcampaintestsuite = campaintestsuite.dup
          newcampaintestsuite.campain_id = newcampain.id
          newcampaintestsuite.save
          
          campaintestsuiteforcedconfigs = CampainTestSuiteForcedConfig.where(:domaine_id => @domaine, :campain_test_suite_id => campaintestsuite.id).all
          campaintestsuiteforcedconfigs.each do |campaintestsuiteforcedconfig|
            newcampaintestsuiteforcedconfig = campaintestsuiteforcedconfig.dup
            newcampaintestsuiteforcedconfig.campain_test_suite_id = newcampaintestsuite.id
            newcampaintestsuiteforcedconfig.save
          end
          
        end
        kop = 1
      end
    end
    flash[:kop] = kop
    redirect_to controller: 'campains', action: 'index'
  end
  
 
  def submit
    mainruns = []
    mainruns << "ok"
    if params[:submitcamp] != nil
      message = t('message.une_erreur_est_survenue')
      typemessage = 'errorMessage'
      begin
        modelaunch = params[:modelaunch]
        is_first = true
        pre_run_id = nil
        params.each do |param|
          if param.to_s.start_with? "chbxinput"
            campain_test_suite_id = params[param.to_s]
            campain_test_suite = CampainTestSuite.where(:id => campain_test_suite_id).first
            computerhost = params["computer" + campain_test_suite_id]
            if campain_test_suite != nil
			  campain = Campain.where(:id => campain_test_suite.campain_id).first
			  cycle = Cycle.where(:id => campain.cycle_id).first
			  release = Release.where(:id => cycle.release_id).first
			  project = Project.where(:id => release.project_id).first
              sheet = Sheet.where(:domaine_id => @domaine, :version_id => @selectedversion, :current_id => campain_test_suite.sheet_id).first
              if sheet != nil
                run = Run.new
                run.domaine_id = @domaine
                run.campain_id = campain_test_suite.campain_id
                run.campain_test_suite_id = campain_test_suite.id
                run.user_id = @my_user_id
                run.run_type = 'suite'
                run.suite_id = sheet.id
                run.version_id = @selectedversion
				
				run.project_id = release.project_id
				run.name = "#{sheet.name}|#{project.name} / #{release.name} / #{cycle.name} / #{campain.name}"[0..499]
				run.private = campain.private
				run.nbtest = Node.select("count(1) as nbtest").where(:domaine_id => @domaine, :sheet_id => sheet.id).first.nbtest.to_s.to_i - 1
				run.nbtestpass = 0
				run.nbtestfail = 0
				run.nbprocfail = 0
				
                run.hostrequest = computerhost
                run.exec_code = "#testclassrequire\n"
                run.conf_string = ""
                if is_first == true or modelaunch != 'sequence'
                  run.status = 'startable'
                else
                  run.status = 'blocked'
                  run.unlock_run_id = pre_run_id
                end
                run.save
                mainruns << run.id 
                campainconfigs = CampainConfig.where(:domaine_id => @domaine, :campain_id => campain_test_suite.campain_id).all
                campainconfigs.each do |campainconfig|
                  forcedconfig = CampainTestSuiteForcedConfig.where(:domaine_id => @domaine, :campain_test_suite_id => campain_test_suite.id, :variable_id => campainconfig.variable_id).first
                  runconfig = RunConfig.new
                  runconfig.run_id = run.id
                  runconfig.domaine_id = @domaine
                  runconfig.variable_id = campainconfig.variable_id
                  if forcedconfig != nil
                    runconfig.variable_value = forcedconfig.variable_value
                  else
                    runconfig.variable_value = campainconfig.variable_value
                  end
                  runconfig.save
                end
				
                Commun.build_sub_run(@domaine, run.suite_id, run.id, sheet.name)
                Commun.saverunsuiteschemes(run)
				
                pre_run_id = run.id
                is_first = false
              end
            end
          end
        end
      
      
        message = t('message.la_campagne_est_soumise')
        typemessage = 'succesMessage'
      rescue Exception => e
        message += " #{e.message}"
      end
      if @ws == nil then 
        messagehtml = "<span id='idspanmessage' class='#{typemessage}' onclick='this.parentNode.removeChild(this)'>#{message}&nbsp;<b>x</b></span>"
      else
        messagehtml = "#{mainruns.join(';')}"
      end
      render html: messagehtml.html_safe 
    else
      render html: "" 
    end
  end
  
  
  
  

  def cover
    @releasecyclecampains = Project.select("projects.id as project_id, 
projects.name as project_name, 
releases.id as release_id, 
releases.name as release_name, 
cycles.id as cycle_id, 
cycles.name as cycle_name, 
campains.id as campain_id, 
campains.name as campain_name, 
campains.private as campain_private")
    .joins("INNER JOIN userprojects on userprojects.domaine_id = projects.domaine_id and userprojects.project_id = projects.id      
LEFT OUTER JOIN releases on  releases.domaine_id = projects.domaine_id and releases.project_id = projects.id      
LEFT OUTER JOIN cycles on  cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id      
LEFT OUTER JOIN campains on  campains.domaine_id = cycles.domaine_id and campains.cycle_id = cycles.id and (campains.private = 0 or campains.owner_user_id = #{@my_user_id})")
    .where("projects.domaine_id = #{@domaine} and userprojects.user_id = #{@my_user_id}" )
    .order("projects.id, releases.id, cycles.id, campains.id").all
 
 
    @displayedelements = cookies[:releasedisplayed]
	
    if params[:campain_id].to_s != "" 
      @campain_id = params[:campain_id]
      buildtestrephtml(params[:campain_id])
    end
  end    






  def wslaunch
	  @domaine = params[:domaine_id]
	  @selectedversion  = params[:version_id]
    user, pwd = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    _encryptedpassword = Commun.get_encrypted_password(pwd)
    wuser = User.where(:domaine_id => @domaine, :login => user, :pwd => _encryptedpassword[0..49]).first
    if wuser != nil and wuser.locked.to_s != "1"
      @my_user_id = wuser.id
      @ws = false
      submit
	  else
	    render html: "{\"result\":\"unauthorized\"}"
	  end
  end
  
  def wscampainresults
	  @domaine = params[:domaine_id]
    user, pwd = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    _encryptedpassword = Commun.get_encrypted_password(pwd)
    wuser = User.where(:domaine_id => @domaine, :login => user, :pwd => _encryptedpassword[0..49]).first
	  retour = ""
    if wuser != nil and wuser.locked.to_s != "1"
      idrun = params[:id]
      run = Run.where(:id => idrun).first
      if run == nil
        retour = "<html><body>no run #{idrun}</body></html>"
      else
        if run.status != "ended"
          retour = "#{run.status}"
        else
          result  = Run.select("runs.id as run_id,  
				sheets.name as suite_name, runs.status,
				count(distinct nodes.id) as nbtest,
				count(distinct case when resulttests.result = 'PASS' then resulttests.id else null end) as nbtestpass,
				count(distinct case when resulttests.result like 'FAIL%' then resulttests.id else null end) as nbtestfail,
				count(distinct case when run_step_results.result = 'PASS' then run_step_results.id else null end) as nbprocpass,
				count(distinct case when run_step_results.result = 'FAIL' then run_step_results.id else null end) as nbprocfail,
				runs.nb_screenshots_diffs as nbwarn")
          .joins("LEFT OUTER JOIN run_step_results on run_step_results.domaine_id = runs.domaine_id and runs.id = run_step_results.run_id and run_step_results.steplevel = 'procedure'")
          .joins("LEFT OUTER JOIN run_step_results as resulttests on resulttests.domaine_id = runs.domaine_id and runs.id = resulttests.run_id and resulttests.steplevel = 'test' and resulttests.result != 'start'")
          .joins("INNER JOIN sheets on sheets.id = runs.suite_id")
          .joins("INNER JOIN nodes on nodes.sheet_id = sheets.id and nodes.domaine_id = sheets.domaine_id and nodes.obj_type='testinsuite'")
          .where("runs.id = #{idrun}")
          .all.order("run_id DESC").group("runs.id, runs.status, sheets.id, runs.nb_screenshots_diffs")
				
          retour = "<html>\n"
          retour += "<head><title>run #{result[0].run_id}</title></head>\n"
          retour += "<body>\n"
          retour += "<table cellpadding='2' cellspacing='0' border='1'>\n"
          retour += "<tr><td rowspan='1' colspan='3'>#{result[0].suite_name}</td></tr>\n"
          retour += "<tr><td>result:</td><td>#{result[0].status}</td></tr>\n"
          retour += "<tr><td>totalTime:</td><td>#{(run.updated_at - run.created_at).to_i}</td></tr>\n"
          retour += "<tr><td>numTestTotal:</td><td>#{result[0].nbtest}</td></tr>\n"
          retour += "<tr><td>numTestPasses:</td><td>#{result[0].nbtestpass}</td></tr>\n"
          retour += "<tr><td>numTestFailures:</td><td>#{result[0].nbtestfail}</td></tr>\n"
          retour += "<tr><td>numCommandPasses:</td><td>#{result[0].nbprocpass}</td></tr>\n"
          retour += "<tr><td>numCommandFailures:</td><td>#{result[0].nbwarn}</td></tr>\n"
          retour += "<tr><td>numCommandErrors:</td><td>#{result[0].nbprocfail}</td></tr>\n"
          retour += "</table>\n"
          retour += "</body>\n"
          retour += "</html>\n"
        end
      end		
	  else
	    retour = "<html><body>unauthorized #{@domaine} #{user} #{pwd} #{wuser}</body></html>"
	  end	
	  render html: retour.html_safe
  end

  private
  
  def lister_folder(folder, parent_id, niveau, type_sheet)
    folder_id = folder.id
    folder_name = folder.name
    decalage = 7
    styledecalage = ""
    for i in 0..niveau
      decalage += 10
      styledecalage = " style='margin-left:#{decalage}px' "
    end

    if SheetFolder.where("sheet_folder_father_id = #{folder_id}").first == nil and Sheet.where(:sheet_folder_id => folder_id, :version_id => @selectedversion).first == nil #pas d'enfant
      if niveau <=1
        @htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage} ><div class='treeline' id='span#{folder_id}' ><span>#{folder_name}</span></div></div></div>"
      else
        @htmlrepertoire += "<div class='treegroupmore' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage} ><div class='treeline' id='span#{folder_id}' ><span>#{folder_name}</span></div></div></div>"
      end  
    else
      if niveau <=1
        if niveau == 0
          signe = "-&nbsp;&nbsp;"
        else
          signe = "+&nbsp;&nbsp;"
        end
        if folder.sheet_folder_father_id == nil #root folder
          @htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showSheetHideSons(\"#{parent_id}-#{folder_id}\", \"#{type_sheet}\")'><b>#{signe}</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' ><span>#{folder_name}</span></div></div>"
        else
          @htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showSheetHideSons(\"#{parent_id}-#{folder_id}\", \"#{type_sheet}\")'><b>#{signe}</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' ><span>#{folder_name}</span></div></div>"
        end
      else
        @htmlrepertoire += "<div class='treegroupmore' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showSheetHideSons(\"#{parent_id}-#{folder_id}\", \"#{type_sheet}\")'><b>+&nbsp;&nbsp;</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' ><span>#{folder_name}</span></div></div>"
      end  
      sons = SheetFolder.select("sheet_folders.*").joins("LEFT OUTER JOIN userprojects on userprojects.project_id = sheet_folders.project_id").where("sheet_folder_father_id = #{folder_id} and type_sheet='#{type_sheet}' and (userprojects.user_id = #{@my_user_id} or sheet_folders.project_id is null)").order("sheet_folders.name").all
      sons.each do |son|
        lister_folder(son, "#{parent_id}-#{folder_id}", niveau+1, type_sheet)
      end
    
      sheets = Sheet.where("sheet_folder_id = #{folder_id} and version_id = #{@selectedversion} and (owner_user_id=#{@my_user_id} or private=0)").order(:name).all
      sheets.each do |sheet|
        styledecalagetest = " style='margin-left:#{decalage+10}px' "
        @htmlrepertoire += "<div class='treegroupmore' name='#{parent_id}-#{folder_id}' id='#{parent_id}-#{folder_id}-sheet#{sheet.id}'><input type='hidden' id='hidoltn#{sheet.id}' value='#{sheet.name.gsub("'","&apos;")}'/><div class='treetest' #{styledecalagetest}><div class='treeline' id='spant#{sheet.id}' ><span>#{sheet.name}</span></div><button class='btnadd' title='#{t('ajouter')}' style='float: right;' onclick='addcampainstep(#{sheet.id});'></button></div></div>"
      end
    
      @htmlrepertoire += "</div>"
    end
  end  
  
  def buildtestrephtml(campain_id)
    root_test_folder = TestFolder.where(:domaine_id => @domaine, :test_folder_father_id => nil).first
    @htmltestrepertoire = ""
    lister_test_folder(root_test_folder, "divrep-0", 0, campain_id)
    @htmltestrepertoire = @htmltestrepertoire.html_safe
  end

  def lister_test_folder(folder, parent_id, niveau, campain_id)
    folder_id = folder.id
    folder_name = folder.name
    decalage = 7
    styledecalage = ""
    for i in 0..niveau
      decalage += 10
      styledecalage = " style='margin-left:#{decalage}px' "
    end

    if TestFolder.where("domaine_id = #{@domaine} and test_folder_father_id = #{folder_id} and is_atdd is null").first == nil and Test.where(:test_folder_id => folder_id, :version_id => @selectedversion).first == nil #pas d'enfant
      if niveau <=1
        @htmltestrepertoire += "<div class='treegroup' npass='0' nfail='0' nnorun='0' nout='0' name='#{parent_id}' id='#{parent_id}-#{folder_id}'>
									<div class='treerep' #{styledecalage}>
										<div class='treeline' id='span#{folder_id}' >
											<span>#{folder_name}</span>
										</div>   
										<div style='width:99%;display:inline-block;'>
											<div style='display:inline-block;background-color:#42f450;width:33%' id='pass#{parent_id}-#{folder_id}'>
											</div>
											<div style='display:inline-block;background-color:#ef0202;width:33%' id='fail#{parent_id}-#{folder_id}'>
											</div>
											<div style='display:inline-block;background-color:orange;width:33%' id='norun#{parent_id}-#{folder_id}'>
											</div>
											<div style='display:inline-block;background-color:#b7b3b3;width:33%' id='nout#{parent_id}-#{folder_id}'>
											</div>
										</div>
									</div>"
      else
        @htmltestrepertoire += "<div class='treegroupmore' npass='0' nfail='0' nnorun='0' nout='0' name='#{parent_id}' id='#{parent_id}-#{folder_id}'>
									<div class='treerep' #{styledecalage}>
										<div class='treeline' id='span#{folder_id}' >
											<span>#{folder_name}</span>
										</div>   
										<div style='width:99%;display:inline-block;'>
											<div style='display:inline-block;background-color:#42f450;width:33%' id='pass#{parent_id}-#{folder_id}'>
											</div>
											<div style='display:inline-block;background-color:#ef0202;width:33%' id='fail#{parent_id}-#{folder_id}'>
											</div>
											<div style='display:inline-block;background-color:orange;width:33%' id='norun#{parent_id}-#{folder_id}'>
											</div>
											<div style='display:inline-block;background-color:#b7b3b3;width:33%' id='nout#{parent_id}-#{folder_id}'>
											</div>
										</div>
									</div>"
      end  
    else
      if niveau <=1
        if niveau == 0
          signe = "-&nbsp;&nbsp;"
        else
          signe = "+&nbsp;&nbsp;"
        end
        @htmltestrepertoire += "<div class='treegroup' npass='0' nfail='0' nnorun='0' nout='0' name='#{parent_id}' id='#{parent_id}-#{folder_id}'>
									<div class='treerep'#{styledecalage}>
										<span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showTestInSuiteHideSons(\"#{parent_id}-#{folder_id}\")'><b>#{signe}</b></span>&nbsp;
										<div class='treeline' id='span#{folder_id}' >
											<span>#{folder_name}</span>
										</div>   
										<div style='width:99%;display:inline-block;'>
											<div style='display:inline-block;background-color:#42f450;width:33%;margin-right:-1px;' id='pass#{parent_id}-#{folder_id}'>
											</div><div style='display:inline-block;background-color:#ef0202;width:33%;margin-right:-1px;' id='fail#{parent_id}-#{folder_id}'>
											</div><div style='display:inline-block;background-color:orange;width:33%;margin-right:-1px;' id='norun#{parent_id}-#{folder_id}'>
											</div><div style='display:inline-block;background-color:#b7b3b3;width:33%;margin-right:-1px;' id='nout#{parent_id}-#{folder_id}'>
											</div>
										</div>
									</div>"
      else
        @htmltestrepertoire += "<div class='treegroupmore' npass='0' nfail='0' nnorun='0' nout='0' name='#{parent_id}' id='#{parent_id}-#{folder_id}'>
									<div class='treerep'#{styledecalage}>
										<span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showTestInSuiteHideSons(\"#{parent_id}-#{folder_id}\")'><b>+&nbsp;&nbsp;</b></span>&nbsp;
										<div class='treeline' id='span#{folder_id}' >
											<span>#{folder_name}</span>
										</div>   
										<div style='width:99%;display:inline-block;'>
											<div style='display:inline-block;background-color:#42f450;width:33%;margin-right:-1px;' id='pass#{parent_id}-#{folder_id}'>
											</div><div style='display:inline-block;background-color:#ef0202;width:33%;margin-right:-1px;' id='fail#{parent_id}-#{folder_id}'>
											</div><div style='display:inline-block;background-color:orange;width:33%;margin-right:-1px;' id='norun#{parent_id}-#{folder_id}'>
											</div><div style='display:inline-block;background-color:#b7b3b3;width:33%;margin-right:-1px;' id='nout#{parent_id}-#{folder_id}'>
											</div>
										</div>
									</div>"
      end  
      sons = TestFolder.select("test_folders.*").joins("LEFT OUTER JOIN userprojects on userprojects.domaine_id = test_folders.domaine_id and userprojects.project_id = test_folders.project_id").where("test_folders.domaine_id = #{@domaine} and is_atdd is null and test_folder_father_id = #{folder_id} and userprojects.user_id = #{@my_user_id}").order("test_folders.name").all
      sons.each do |son|
        lister_test_folder(son, "#{parent_id}-#{folder_id}", niveau+1, campain_id)
      end

      tests = Test.select("tests.id, 
	  tests.name, 
	  tests.private, 
	  tests.test_type_id, 
	  sum(case when run_step_results.result = 'PASS' then 1 else 0 end) as nbpass, 
	  sum(case when run_step_results.result is not null and run_step_results.result != 'PASS' then 1 else 0 end) as nbfail, 
	  sum(case when run_step_results.result is null and campain_test_suites.id is not null then 1 else 0 end) as nbnorun, 
	  sum(case when campain_test_suites.id is null then 1 else 0 end) as nbout ")
      .joins("LEFT OUTER JOIN run_step_results on 
			run_step_results.domaine_id = tests.domaine_id and 
			run_step_results.test_id = tests.current_id and 
			steplevel='test' and run_step_results.run_id in (select id from runs where runs.domaine_id = #{@domaine} and runs.campain_id = #{campain_id} )")
      .joins("LEFT JOIN nodes on nodes.domaine_id = tests.domaine_id and nodes.obj_type = 'testinsuite' and nodes.obj_id = tests.id")
      .joins("LEFT JOIN campain_test_suites on campain_test_suites.domaine_id = tests.domaine_id and campain_test_suites.sheet_id = nodes.sheet_id and campain_test_suites.campain_id = #{campain_id}")
      .where("tests.domaine_id = #{@domaine} and tests.test_folder_id = #{folder_id} and tests.version_id = #{@selectedversion} and (tests.owner_user_id=#{@my_user_id} or tests.private=0) and tests.test_type_id is not null").order(:name).group("tests.id, tests.name, tests.private, tests.test_type_id").all
      tests.each do |test|
        marqueprivate = ""
        if test.private == 1
          marqueprivate = "<div class='marqueprivate' style='float: left;' title='#{t('prive')}'></div>"
        end
        styledecalagetest = " style='margin-left:#{decalage+10}px' "
        if test.nbpass + test.nbfail + test.nbnorun  == 0
          @htmltestrepertoire += "<div class='testmore' name='#{parent_id}-#{folder_id}' id='#{parent_id}-#{folder_id}-test#{test.id}' nfail='#{test.nbfail}' npass='#{test.nbpass}' nnorun='#{test.nbnorun}' nout='1'>
										<div id='treetest#{test.id}' class='treetest' #{styledecalagetest} name='testitem' >#{marqueprivate}
											<div class='treeline' id='spant#{test.id}' ><span>#{test.name}</span>"
        else
          @htmltestrepertoire += "<div class='testmore' name='#{parent_id}-#{folder_id}' id='#{parent_id}-#{folder_id}-test#{test.id}' nfail='#{test.nbfail}' npass='#{test.nbpass}' nnorun='#{test.nbnorun}' nout='0'>
										<div id='treetest#{test.id}' class='treetest' #{styledecalagetest} name='testitem' >#{marqueprivate}
											<div class='treeline' id='spant#{test.id}' ><span>#{test.name}</span>"
        end
        if test.nbpass > 0 then @htmltestrepertoire += "<span style='float:right;margin-left:5px;color:green' >#{test.nbpass} PASS</span>" end
        if test.nbfail > 0 then @htmltestrepertoire += "<span style='float:right;margin-left:5px;color:red'>#{test.nbfail} FAIL</span>" end
        if test.nbnorun > 0 then @htmltestrepertoire += "<span style='float:right;margin-left:5px;color:orange'>#{test.nbnorun} NO RUN</span>" end
        if test.nbpass + test.nbfail + test.nbnorun  == 0 then @htmltestrepertoire += "<span style='float:right;margin-left:5px;color:black'>OUT</span>" end
        @htmltestrepertoire += "</div></div></div>"
      end
	  
    end
    @htmltestrepertoire += "</div>"
  end     
  
end
