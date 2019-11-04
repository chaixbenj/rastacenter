class TypeFichesController < ApplicationController
  before_action :require_login

  
  def index
    type_fiche_id = (params[:type_fiche_id] != nil ? params[:type_fiche_id] : flash[:type_fiche_id]).to_s
    @name = params[:sname].to_s
    if @name != ""
      @type_fiches = TypeFiche.where("domaine_id = #{@domaine} and name like '%#{@name}%'").order(:name).all
    else  
      @type_fiches = TypeFiche.where("domaine_id = #{@domaine}").order(:name).all
    end 
    @workflow = Sheet.where(:domaine_id => @domaine, :type_sheet => "workflow").first
    @message = nil
    
    if type_fiche_id != ""
	  @message, @OK = Commun.set_message(flash[:ko])
      @type_fiche = TypeFiche.where(:id => type_fiche_id).first
      if Fiche.where(:domaine_id => @domaine, :type_fiche_id => type_fiche_id).first == nil
        @is_used = false 
      else
        @is_used = true
      end
      preposy = nil
      bloc_custo = nil
      @nextline = 4
      if @type_fiche != nil
        @listes = Liste.where(:domaine_id => @domaine).all.order(:name)
        @workflows = Sheet.where(:domaine_id => @domaine, :type_sheet => "workflow").all.order(:name)
        if @type_fiche.jsondesc.to_s != nil
          bloc_custo = ""
          if @type_fiche.jsondesc != nil
            jsondesc = JSON.parse(@type_fiche.jsondesc, :quirks_mode => true)
          else
            jsondesc = []
          end
          nbrow = 4
          for i in 0..jsondesc.length-1
            pos = jsondesc[i]["pos"].to_s.split('-')
            if pos[0] != preposy  
              nbrow += 1
              @nextline = nbrow
              bloc_custo = bloc_custo.gsub("newcustobloc1", "").gsub("newcustobloc2", "").gsub("newcustobloc3", "")
              bloc_custo += "<tr><td border=\"2\" bgcolor=\"#6FEF99\" id=\"#{nbrow}-1\" draggable=\"true\" ondragover=\"draggingTypeFicheOver(event, this)\" ondrop=\"droppedTypeFiche(event, this);nextUCFdispo();\">&nbsp;newcustobloc1</td><td bgcolor=\"#6FEF99\" id=\"#{nbrow}-2\"  draggable=\"true\" ondragover=\"draggingTypeFicheOver(event, this)\" ondrop=\"droppedTypeFiche(event, this);nextUCFdispo();\">&nbsp;newcustobloc2</td><td bgcolor=\"#6FEF99\" id=\"#{nbrow}-3\"  draggable=\"true\" ondragover=\"draggingTypeFicheOver(event, this)\" ondrop=\"droppedTypeFiche(event, this);nextUCFdispo();\">&nbsp;newcustobloc3</td></tr>";
            end
            divpos = "#{nbrow}-#{pos[1]}"
            custodiv = "<div id='insertcustofield#{divpos}' draggable='true' ondragstart='dragTypeFicheStarted(event, this)' class='elembleu' role='div' name='insertcustofield#{divpos}'>"
            custodiv += "<input class='inputbox' disabled type='text' size='5' id='#{jsondesc[i]["user_custo_field"]}' value='#{jsondesc[i]["user_custo_field"]}' role='ucf' name='ucf#{divpos}'/>"
            custodiv += "<input type='hidden' size='5' id='#{jsondesc[i]["user_custo_field"]}' value='#{jsondesc[i]["user_custo_field"]}' role='ucfh' name='ucfh#{divpos}'/>"
            custodiv += "<input class='inputbox' id='cn#{divpos}' role='cn' name='cn#{divpos}' value='#{jsondesc[i]["name"]}' type='text' size='10' maxlength='100' placeholder='#{t('nom')}' onKeyDown='showvalidbtn();' />"
            custodiv += "<select class='inputbox' id='ct#{divpos}' role='ct' name='ct#{divpos}' onchange='showvalidbtn();active_choix_liste(this.value, \"select_liste#{divpos}\");'>"

            if jsondesc[i]["type"] == 'text' then textselected = "selected" else textselected = "" end
            if jsondesc[i]["type"] == 'list' then listselected = "selected" else listselected = "" end
            if jsondesc[i]["type"] == 'textarea' then textareaselected = "selected" else textareaselected = "" end
            custodiv += "<option #{textselected} value='text'>#{t('ecr_type_fiche.type_text')}</option>"
            custodiv += "<option #{listselected} value='list'>#{t('ecr_type_fiche.type_list')}</option>"
            custodiv += "<option #{textareaselected} value='textarea'>#{t('ecr_type_fiche.type_textarea')}</option>"
            custodiv += "</select>"

            if jsondesc[i]["type"] == 'list' then stylelist = "style='display:inline;'" else stylelist = "style='display:none;'" end
            custodiv += "<select #{stylelist} class='inputbox' id='select_liste#{divpos}' name='ccl#{divpos}' role='ccl' onchange='showvalidbtn();'>"		

            if jsondesc[i]["code_liste"].to_s == 'user' then listselected = "selected" else listselected = "" end
            custodiv += "<option #{listselected} value='user'>#{t('ecr_type_fiche.utilisateurs')}</option>"
            if jsondesc[i]["code_liste"].to_s == 'project' then listselected = "selected" else listselected = "" end
            custodiv += "<option #{listselected} value='project'>#{t('ecr_type_fiche.projets')}</option>"
            if jsondesc[i]["code_liste"].to_s == 'release' then listselected = "selected" else listselected = "" end
            custodiv += "<option #{listselected} value='release'>#{t('ecr_type_fiche.releases')}</option>"
            if jsondesc[i]["code_liste"].to_s == 'cycle' then listselected = "selected" else listselected = "" end
            custodiv += "<option #{listselected} value='cycle'>#{t('ecr_type_fiche.cycles')}</option>"
            if jsondesc[i]["code_liste"].to_s == 'campain' then listselected = "selected" else listselected = "" end
            custodiv += "<option #{listselected} value='campain'>#{t('ecr_type_fiche.campains')}</option>"
            if jsondesc[i]["code_liste"].to_s == 'schemaapp' then listselected = "selected" else listselected = "" end
            custodiv += "<option #{listselected} value='schemaapp'>#{t('ecr_type_fiche.schemaapps')}</option>"
            if jsondesc[i]["code_liste"].to_s == 'funcandscreen' then listselected = "selected" else listselected = "" end
            custodiv += "<option #{listselected} value='funcandscreen'>#{t('ecr_type_fiche.funcandscreens')}</option>"
            if jsondesc[i]["code_liste"].to_s == 'test' then listselected = "selected" else listselected = "" end
            custodiv += "<option #{listselected} value='test'>#{t('ecr_type_fiche.tests')}</option>"
            if jsondesc[i]["code_liste"].to_s == 'testsuite' then listselected = "selected" else listselected = "" end
            custodiv += "<option #{listselected} value='testsuite'>#{t('ecr_type_fiche.testsuites')}</option>"
            if @listes != nil
              @listes.each do |liste|
                if jsondesc[i]["code_liste"].to_s == liste.code then listselected = "selected" else listselected = "" end 
                custodiv += "<option #{listselected} value='#{liste.code}'>#{liste.name}</option>"
              end
            end
            custodiv += "</select>"
				
            if jsondesc[i]["required"] == 'on' then requiredchecked = "checked" else requiredchecked = "" end
            custodiv += "<input #{requiredchecked} class='inputbox' id='cobl#{divpos}' role='cobl' name='cobl#{divpos}' type='checkbox' onclick='showvalidbtn();'><span class='textStyle' name='spanobl#{divpos}' id='spanobl#{divpos}'>#{t('obligatoire')}</span></input>"
            custodiv += "<div class='btndel' onclick='this.parentNode.remove(this);showvalidbtn();' id='btndel#{divpos}' name='btndel#{divpos}'></div>"
            custodiv += "</div>"
				
            bloc_custo = bloc_custo.gsub("newcustobloc#{pos[1]}", custodiv)
            preposy = pos[0]
          end
          bloc_custo = bloc_custo.gsub("newcustobloc1", "").gsub("newcustobloc2", "").gsub("newcustobloc3", "")
          @bloc_custo = bloc_custo.html_safe

        end
      end
    end    
  end  
    

   
  def update
    name = params[:name]
    type_fiche_id = params[:type_fiche_id].to_s
    if @can_manage_worflows_and_card == 1
      if params[:delete] != nil
        type_fiche = TypeFiche.where(:id => type_fiche_id).first
        if type_fiche != nil 
          KanbanTypeFiche.where(:domaine_id => @domaine, :type_fiche_id => type_fiche.id).delete_all
          type_fiche.destroy
        end
      end

      if params[:valid] != nil
        type_fiche = TypeFiche.where(:id => type_fiche_id).first
        flash[:ko] = 1
        if type_fiche != nil and TypeFiche.where("domaine_id = #{@domaine} and name = \"#{name}\" and id != #{type_fiche_id}").first == nil
          type_fiche.name = name
          if params[:workflow].to_s != "" then type_fiche.sheet_id = params[:workflow] end
          if params[:color].to_s != "" then type_fiche.color = params[:color] end
          jsonfic = ""
          i = 0
          params.each do |param|
            if param.to_s.start_with? "ucfh"
              nomparam = param.to_s
              if params[nomparam].to_s != ""
                i += 1
                if i > 1 then jsonfic += "," end
                pos = nomparam.gsub('ucfh', '')
                jsonfic += "{\"user_custo_field\":\"#{params[nomparam]}\",\"name\":\"#{params[nomparam.gsub('ucfh', 'cn')]}\",\"pos\":\"#{pos}\",\"type\":\"#{params[nomparam.gsub('ucfh', 'ct')]}\",\"code_liste\":\"#{params[nomparam.gsub('ucfh', 'ccl')].to_s}\",\"required\":\"#{params[nomparam.gsub('ucfh', 'cobl')].to_s}\"}"
              end
            end
          end
          jsonfic = "[#{jsonfic}]"	
          type_fiche.jsondesc = jsonfic
		  if params[:gherkin] != nil then type_fiche.is_gherkin = 1 else type_fiche.is_gherkin = 0 end
          type_fiche.save
        else
          flash[:ko] = 13
        end
		flash[:type_fiche_id] = type_fiche.id
      end    
    end
	redirect_to controller: 'type_fiches', action: 'index'
  end  

  def getone
	flash[:type_fiche_id] = params[:type_fiche_id].to_s
	redirect_to controller: 'type_fiches', action: 'index'
  end
  
  def new
    if @can_manage_worflows_and_card == 1 
      if  TypeFiche.where(:domaine_id => @domaine, :name => params[:namec].to_s).first != nil
        flash[:ko] = 13 
      else
        type_fiche = TypeFiche.new
        type_fiche.name =  params[:namec][0..250]
        type_fiche.domaine_id = @domaine
        type_fiche.is_system = 0
        type_fiche.color = "#ff0000"
        workflow = Sheet.where(:domaine_id => @domaine, :type_sheet => "workflow").first
        type_fiche.sheet_id = workflow.id
        type_fiche.save
		flash[:type_fiche_id] = type_fiche.id
      end
	  redirect_to controller: 'type_fiches', action: 'index'
    end
  end  
 



  def show
    type_fiche_id = params[:type_fiche_id].to_s
    @popup = 	params[:popup].to_s
    @type_fiche = TypeFiche.where(:id => type_fiche_id).first

    preposy = nil
    bloc_custo = nil
    @nextline = 4
    if @type_fiche != nil
      @listes = Liste.where(:domaine_id => @domaine).all.order(:name)
      @all_status = Node.select("nodes.obj_id as id, nodes.name as value, nodes.obj_type as type")
      .joins("INNER JOIN sheets on sheets.domaine_id = nodes.domaine_id and sheets.id = nodes.sheet_id")
      .where("nodes.domaine_id = #{@domaine} and sheets.id =#{@type_fiche.sheet_id}").all.order("nodes.id_externe")

      @all_priorities = Liste.select("liste_values.*").joins("INNER JOIN liste_values on listes.domaine_id = liste_values.domaine_id and listes.id = liste_values.liste_id").where("listes.domaine_id = #{@domaine} and listes.code ='PRIORITY'").all.order("liste_values.value")

      @all_cycles = Cycle.select("cycles.id, cycles.name as value")
      .joins("INNER JOIN releases on cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id")
      .joins("INNER JOIN userprojects  on userprojects.domaine_id = releases.domaine_id and userprojects.project_id = releases.project_id and userprojects.user_id = #{@my_user_id}")
      .where("cycles.domaine_id = #{@domaine}").all.order("cycles.name") 
 
      @all_users = User.select("distinct users.id, users.username as value")
      .joins("INNER JOIN userprojects as otherusersprojects  on otherusersprojects.domaine_id = users.domaine_id and otherusersprojects.user_id = users.id")
      .joins("INNER JOIN userprojects as myusersprojects  on myusersprojects.domaine_id = users.domaine_id and myusersprojects.project_id = otherusersprojects.project_id and myusersprojects.user_id = #{@my_user_id}")
      .where("users.domaine_id = #{@domaine}").all.order("users.username") 
            
             
      if @type_fiche.jsondesc.to_s != nil
        @type_fiche.jsondesc.to_s.include? 'code_liste":"project"'
        all_projects = Project.select("projects.id, projects.name as value")
        .joins("INNER JOIN userprojects  on userprojects.domaine_id = projects.domaine_id and userprojects.project_id = projects.id and userprojects.user_id = #{@my_user_id}")
        .where("projects.domaine_id = #{@domaine}").all.order("projects.name") 
      end 

      if @type_fiche.jsondesc.to_s.include? 'code_liste":"release"'
        all_releases = Release.select("releases.id, releases.name as value")
        .joins("INNER JOIN projects on projects.domaine_id = releases.domaine_id and projects.id = releases.project_id")
        .joins("INNER JOIN userprojects  on userprojects.domaine_id = releases.domaine_id and userprojects.project_id = releases.project_id and userprojects.user_id = #{@my_user_id} and userprojects.project_id = #{@selectedproject}")
        .where("releases.domaine_id = #{@domaine}").all.order("releases.name") 
      end 
            
           
      if @type_fiche.jsondesc.to_s.include? 'code_liste":"campain"'
        all_campains = Campain.select("campains.id, campains.name as value")
        .joins("INNER JOIN cycles on cycles.domaine_id = campains.domaine_id and cycles.id = campains.cycle_id")
        .joins("INNER JOIN releases on cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id")
        .joins("INNER JOIN userprojects  on userprojects.domaine_id = releases.domaine_id and userprojects.project_id = releases.project_id and userprojects.user_id = #{@my_user_id} and userprojects.project_id = #{@selectedproject}")
        .where("cycles.domaine_id = #{@domaine}").all.order("campains.name") 
      end 

      if @type_fiche.jsondesc.to_s.include? 'code_liste":"funcandscreen"'
        all_funcandscreens = Funcandscreen.select("distinct funcandscreens.id, sheets.name as value2, funcandscreens.name as value")
        .joins("INNER JOIN nodes on nodes.domaine_id = funcandscreens.domaine_id and nodes.obj_id = funcandscreens.id and nodes.obj_type='funcscreen'")
        .joins("INNER JOIN sheets on sheets.domaine_id = nodes.domaine_id and sheets.id = nodes.sheet_id and (sheets.private = 0 or sheets.owner_user_id=#{@my_user_id})")
        .joins("INNER JOIN userprojects on userprojects.domaine_id = funcandscreens.domaine_id and userprojects.project_id = funcandscreens.project_id and userprojects.project_id = #{@selectedproject}")
        .where("sheets.version_id = #{@currentversion} and funcandscreens.domaine_id =  #{@domaine} and userprojects.user_id = #{@my_user_id}")
        .order("sheets.name, funcandscreens.name").all	  
      end 

      if @type_fiche.jsondesc.to_s.include? 'code_liste":"schemaapp"'
        all_schemaapps = Sheet.select("sheets.id, sheets.name as value")
        .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
        .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id and userprojects.user_id = #{@my_user_id} and userprojects.project_id = #{@selectedproject}")
        .joins("INNER JOIN projects on projects.id = sheet_folders.project_id").where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@currentversion} and sheets.type_sheet='conception_sheet' and (sheets.private=0 or  sheets.owner_user_id = #{@my_user_id})")
        .order("sheets.name").all
      end 

      if @type_fiche.jsondesc.to_s.include? 'code_liste":"testsuite"'
        all_testsuites = Sheet.select("sheets.id, sheets.name as value")
        .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
        .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id and userprojects.user_id = #{@my_user_id} and userprojects.project_id = #{@selectedproject}")
        .joins("INNER JOIN projects on projects.id = sheet_folders.project_id").where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@currentversion} and sheets.type_sheet='test_suite' and (sheets.private=0 or  sheets.owner_user_id = #{@my_user_id})")
        .order("sheets.name").all
      end 

      if @type_fiche.jsondesc.to_s.include? 'code_liste":"test"'
        all_tests = Test.select("tests.id, tests.name as value")
        .joins("INNER JOIN test_folders on test_folders.id = tests.test_folder_id")
        .joins("INNER JOIN userprojects on userprojects.domaine_id = test_folders.domaine_id and userprojects.project_id = test_folders.project_id  and userprojects.user_id = #{@my_user_id} and userprojects.project_id = #{@selectedproject}")
        .where("tests.domaine_id = #{@domaine} and tests.version_id = #{@currentversion} and (tests.owner_user_id=#{@my_user_id} or tests.private=0)")
        .order("tests.name").all
      end


      bloc_custo = ""
      if @type_fiche.jsondesc != nil
        jsondesc = JSON.parse(@type_fiche.jsondesc.to_s, :quirks_mode => true)
      else
        jsondesc = JSON.parse("[]", :quirks_mode => true)
      end
      for i in 0..jsondesc.length-1
        pos = jsondesc[i]["pos"].to_s.split('-')
        if pos[0] != preposy  
          bloc_custo = bloc_custo.gsub("newcustobloc1", "").gsub("newcustobloc2", "").gsub("newcustobloc3", "")
          bloc_custo += "<tr><td>newcustobloc1</td><td>newcustobloc2</td><td>newcustobloc3</td></tr>";
        end
        custodiv = "<span class='textStyle'>#{jsondesc[i]["name"]}</span></td><td>"
        if jsondesc[i]["required"] == 'on' then requiredfield = "required" else requiredfield = "" end
        if jsondesc[i]["type"] == 'text' 
          custodiv += "<input #{requiredfield} type='text' class='inputbox' name='#{jsondesc[i]["user_custo_field"]}'/>"
        end
        if jsondesc[i]["type"] == 'textarea' 
          custodiv += "<br><textarea #{requiredfield} cols='' rows='5' class='inputbox' style='width:85%' name='#{jsondesc[i]["user_custo_field"]}'></textarea>"
        end
        if jsondesc[i]["type"] == 'list' 
          custodiv += "<select #{requiredfield} class='inputbox' name='#{jsondesc[i]["user_custo_field"]}'>"	
          code_liste = jsondesc[i]["code_liste"]
                  
          case code_liste
          when "user"
            listevalues = @all_users
          when "project"
            listevalues = all_projects
          when "release"
            listevalues = all_releases
          when "cycle"
            listevalues = @all_cycles
          when "campain"
            listevalues = all_campains
          when "schemaapp"
            listevalues = all_schemaapps
          when "funcandscreen"
            listevalues = all_funcandscreens
          when "test"
            listevalues = all_tests
          when "testsuite"
            listevalues = all_testsuites
          else
            liste = Liste.where(:domaine_id => @domaine, :code => code_liste).first
            if liste != nil
              listevalues = ListeValue.where(:domaine_id => @domaine, :liste_id => liste.id).order(:value).all
            end
          end
          if listevalues != nil
            listevalues.each do |listevalue|
              custodiv += "<option value='#{listevalue.id}-#{listevalue.value}'>#{listevalue.value}</option>"
            end
          end
                
          custodiv += "</select>"	
        end

				
        bloc_custo = bloc_custo.gsub("newcustobloc#{pos[1]}", custodiv)
        preposy = pos[0]
      end
      bloc_custo = bloc_custo.gsub("newcustobloc1", "").gsub("newcustobloc2", "").gsub("newcustobloc3", "")
      @bloc_custo = bloc_custo.html_safe

    end
  end    
    


  
end

	  
	  
	  