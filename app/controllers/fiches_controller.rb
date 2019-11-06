class FichesController < ApplicationController
  before_action :require_login




  def new
    type_fiche_name = params[:type_fiche].to_s
	@father_id = params[:father_id].to_s
    step_id = params[:step_id].to_s
    type_fiche = TypeFiche.where("domaine_id = #{@domaine} and name = '#{type_fiche_name}'").first
    if type_fiche != nil
      redirect_to controller: 'fiches', action: 'edit',  type_fiche_id: type_fiche.id, step_id: step_id
    else
      @popup = "true"
      @type_fiches = TypeFiche.where("domaine_id = #{@domaine} and sheet_id is not null").order(:name).all
      if @type_fiches != nil and @type_fiches.length == 1
        type_fiche = TypeFiche.where("domaine_id = #{@domaine} and sheet_id is not null").first
        redirect_to controller: 'fiches', action: 'edit',  type_fiche_id: type_fiche.id
      end
    end
  end




  def edit
	selectedproject = @selectedproject
    @popup = 	"true"
    @step_id = params[:step_id].to_s
	@onglet = params[:onglet]
    @father_id = params[:father_id].to_s
	@cycle_id = 0
	if @step_id != ""
		cycle = Cycle.joins("INNER JOIN campains on campains.domaine_id = cycles.domaine_id and campains.cycle_id = cycles.id")
					.joins("INNER JOIN runs on runs.domaine_id = campains.domaine_id and campains.id = runs.campain_id")
					.joins("INNER JOIN run_step_results on runs.domaine_id = run_step_results.domaine_id and run_step_results.run_id = runs.id")
					.where("run_step_results.id = #{@step_id}").first
		if cycle != nil then @cycle_id = cycle.id end
	end

    fiche_id = params[:fiche_id].to_s
    @fiche = Fiche.where(:domaine_id => @domaine, :id => fiche_id).first
    if @fiche == nil and params[:fiche_id] != nil
      @noresult = true
    else
	  if @fiche != nil then @selectedproject = @fiche.project_id end
	  if @fiche!= nil and @fiche.father_id != nil then @father = Fiche.select("fiches.id, fiches.name, type_fiches.name as typename, type_fiches.color").joins("INNER JOIN type_fiches on type_fiches.domaine_id = fiches.domaine_id and type_fiches.id = fiches.type_fiche_id").where(:domaine_id => @domaine, :id => @fiche.father_id).first end
	  if @fiche!= nil and @fiche.lignee_id != nil then @lignee = Fiche.select("fiches.id, fiches.name, type_fiches.name as typename, type_fiches.color").joins("INNER JOIN type_fiches on type_fiches.domaine_id = fiches.domaine_id and type_fiches.id = fiches.type_fiche_id").where(:domaine_id => @domaine, :lignee_id => @fiche.lignee_id).order("type_fiche_id, fiches.id").all end
      @noresult = false
	  @test_linked = Test.select(:id, :name).where(:domaine_id => @domaine, :fiche_id => fiche_id).all
      fiche_status = nil
	  type_fiche = nil
      if @fiche != nil
        @fiche_id = @fiche.id
        @type_fiche_id = @fiche.type_fiche_id
		type_fiche = TypeFiche.where(:id => @type_fiche_id).first
        @project_fiche = Project.where(:id => @fiche.project_id).first.name
		@project_fiche_id = @fiche.project_id
        @comments = FicheHisto.select("id, comment, user_cre, created_at").where("domaine_id = #{@domaine} and fiche_id = #{fiche_id} and comment is not null").all.order("created_at DESC")
        @histos = FicheHisto.select("id, jsondesc, user_cre, created_at").where("domaine_id = #{@domaine} and fiche_id = #{fiche_id} and comment is null").all.order("created_at DESC")
        fiche_status = @fiche.status_id
		@downloads = FicheDownload.where("domaine_id = #{@domaine} and fiche_id = #{fiche_id}").all
      else
        @fiche_id = ""
        @type_fiche_id = params[:type_fiche_id].to_s
		@project_fiche_id = @selectedproject
		type_fiche = TypeFiche.where(:id => @type_fiche_id).first
        @project_fiche = Project.where(:id => @selectedproject).first.name
		if type_fiche.is_gherkin == 1
			@model = "\nBackground:\n\tGiven\n\tWhen\n\tThen\n\tAnd\n\tBut\n\nScenario:\n\tGiven\n\tWhen\n\tThen\n\tAnd\n\tBut\n\nScenario Outline:\n\tGiven\n\tWhen\n\tThen\n\tAnd\n\tBut\n\nExamples:\n|header|...|\n|values|...|\n|values|...|\n"
		end
      end
	  @is_gherkin = type_fiche.is_gherkin
	  if @is_gherkin==1 then
		@atddsteps = Test.select("description").where("domaine_id = #{@domaine} and is_atdd = 2").all
	  end
      @type_fiches  = TypeFiche.select("id, name").where(:domaine_id => @domaine).all
      @color = type_fiche.color

      preposy = nil
      bloc_custo = nil
      @nextline = 4
      if type_fiche != nil
        @listes = Liste.where(:domaine_id => @domaine).all.order(:name)
        if fiche_status == nil
          @all_status = Node.select("nodes.obj_id as id, nodes.name as value, nodes.obj_type as type")
          .joins("INNER JOIN sheets on sheets.domaine_id = nodes.domaine_id and sheets.id = nodes.sheet_id")
          .where("nodes.domaine_id = #{@domaine} and sheets.id =#{type_fiche.sheet_id}").all.order("nodes.id")
        else
          @all_status = Sheet.select("distinct availstatus.obj_id as id, availstatus.name as value, availstatus.obj_type as type")
          .joins("INNER JOIN links on links.domaine_id = sheets.domaine_id and links.sheet_id = sheets.id")
          .joins("INNER JOIN nodes on links.domaine_id = nodes.domaine_id and links.sheet_id = nodes.sheet_id and (links.node_father_id_fk = nodes.id_externe or links.node_son_id_fk = nodes.id_externe) and nodes.obj_id = #{fiche_status}")
          .joins("INNER JOIN nodes as availstatus on links.domaine_id = availstatus.domaine_id and links.sheet_id = availstatus.sheet_id and (links.node_father_id_fk = availstatus.id_externe or links.node_son_id_fk = availstatus.id_externe)")
          .where("sheets.domaine_id = #{@domaine} and sheets.id =#{type_fiche.sheet_id}").all.order("availstatus.obj_id")
          if @all_status == nil or @all_status.length == 0
            @all_status = Node.select("nodes.obj_id as id, nodes.name as value, nodes.obj_type as type")
            .joins("INNER JOIN sheets on sheets.domaine_id = nodes.domaine_id and sheets.id = nodes.sheet_id")
            .where("nodes.domaine_id = #{@domaine} and sheets.id =#{type_fiche.sheet_id}").all.order("nodes.obj_id")
          end
        end

        @all_priorities = Liste.select("liste_values.*").joins("INNER JOIN liste_values on listes.domaine_id = liste_values.domaine_id and listes.id = liste_values.liste_id").where("listes.domaine_id = #{@domaine} and listes.code ='PRIORITY'").all.order("liste_values.value")

        @all_cycles = Cycle.select("cycles.id, cycles.name as value")
        .joins("INNER JOIN releases on cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id")
        .where("cycles.domaine_id = #{@domaine} and releases.project_id = #{@selectedproject}").all.order("cycles.name")

        @all_users = User.select("distinct users.id, users.username as value")
        .joins("INNER JOIN userprojects as otherusersprojects  on otherusersprojects.domaine_id = users.domaine_id and otherusersprojects.user_id = users.id")
        .where("users.domaine_id = #{@domaine} and otherusersprojects.project_id = #{@selectedproject}").all.order("users.username")


        if type_fiche.jsondesc.to_s != nil
          type_fiche.jsondesc.to_s.include? 'code_liste":"project"'
          all_projects = Project.select("projects.id, projects.name as value")
          .joins("INNER JOIN userprojects  on userprojects.domaine_id = projects.domaine_id and userprojects.project_id = projects.id and userprojects.user_id = #{@my_user_id}")
          .where("projects.domaine_id = #{@domaine}").all.order("projects.name")
        end

        if type_fiche.jsondesc.to_s.include? 'code_liste":"release"'
          all_releases = Release.select("releases.id, releases.name as value")
          .where("releases.domaine_id = #{@domaine} and releases.project_id = #{@selectedproject}").all.order("releases.name")
        end


        if type_fiche.jsondesc.to_s.include? 'code_liste":"campain"'
          all_campains = Campain.select("campains.id, campains.name as value")
          .joins("INNER JOIN cycles on cycles.domaine_id = campains.domaine_id and cycles.id = campains.cycle_id")
          .joins("INNER JOIN releases on cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id")
          .where("cycles.domaine_id = #{@domaine} and releases.project_id = #{@selectedproject}").all.order("campains.name")
        end

        if type_fiche.jsondesc.to_s.include? 'code_liste":"funcandscreen"'
          all_funcandscreens = Funcandscreen.select("distinct funcandscreens.id, sheets.name as value2, funcandscreens.name as value")
          .joins("INNER JOIN nodes on nodes.domaine_id = funcandscreens.domaine_id and nodes.obj_id = funcandscreens.id and nodes.obj_type='funcscreen'")
          .joins("INNER JOIN sheets on sheets.domaine_id = nodes.domaine_id and sheets.id = nodes.sheet_id and sheets.private = 0")
          .where("sheets.version_id = #{@currentversion} and funcandscreens.domaine_id =  #{@domaine} and funcandscreens.project_id = #{@selectedproject}")
          .order("sheets.name, funcandscreens.name").all
        end

        if type_fiche.jsondesc.to_s.include? 'code_liste":"schemaapp"'
          all_schemaapps = Sheet.select("sheets.id, sheets.name as value")
          .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
          .where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@currentversion} and sheets.type_sheet='conception_sheet' and sheets.private=0 and sheet_folders.project_id = #{@selectedproject}")
          .order("sheets.name").all
        end

        if type_fiche.jsondesc.to_s.include? 'code_liste":"testsuite"'
          all_testsuites = Sheet.select("sheets.id, sheets.name as value")
          .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
          .where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@currentversion} and sheets.type_sheet='test_suite' and sheets.private=0 and sheet_folders.project_id = #{@selectedproject}")
          .order("sheets.name").all
        end

        if type_fiche.jsondesc.to_s.include? 'code_liste":"test"'
          all_tests = Test.select("tests.id, tests.name as value")
          .joins("INNER JOIN test_folders on test_folders.id = tests.test_folder_id")
          .where("tests.domaine_id = #{@domaine} and tests.version_id = #{@currentversion} and tests.private=0 and test_folders.project_id = #{@selectedproject}")
          .order("tests.name").all
        end


        bloc_custo = ""
        if type_fiche.jsondesc != nil then
          jsondesc = JSON.parse(type_fiche.jsondesc, :quirks_mode => true)
        else
          jsondesc = []
        end
        for i in 0..jsondesc.length-1
          pos = jsondesc[i]["pos"].to_s.split('-')
          if pos[0] != preposy
            bloc_custo = bloc_custo.gsub("newcustobloc1", "").gsub("newcustobloc2", "").gsub("newcustobloc3", "")
            bloc_custo += "<tr><td>newcustobloc1</td><td>newcustobloc2</td><td>newcustobloc3</td></tr>";
          end
          custodiv = "<span class='textStyle'>#{jsondesc[i]["name"]}</span></td><td>"
          custodiv += "<input type='hidden' name='name#{jsondesc[i]["user_custo_field"]}' value='#{jsondesc[i]["name"]}'/>"
          if jsondesc[i]["required"] == 'on' then requiredfield = "required" else requiredfield = "" end
          if jsondesc[i]["type"] == 'text'
            value = ""
            if @fiche != nil
                custo_field = FicheCustoField.where(:domaine_id => @domaine, :fiche_id => @fiche.id, :ucf_id => jsondesc[i]["user_custo_field"]).first
                if custo_field != nil
                  value = custo_field.field_value
                end
            end
            custodiv += "<input #{requiredfield} type='text' class='inputbox' name='#{jsondesc[i]["user_custo_field"]}' value='#{value}'/>"
          end
          if jsondesc[i]["type"] == 'textarea'
            value = ""
            if @fiche != nil
                custo_field = FicheCustoField.where(:domaine_id => @domaine, :fiche_id => @fiche.id, :ucf_id => jsondesc[i]["user_custo_field"]).first
                if custo_field != nil
                  value = custo_field.field_value
                end
            end
            custodiv += "<br><textarea #{requiredfield} cols='' rows='5' class='inputbox' style='width:85%' name='#{jsondesc[i]["user_custo_field"]}'>#{value}</textarea>"
          end
          if jsondesc[i]["type"] == 'list'
            custodiv += "<select #{requiredfield} class='inputbox' name='#{jsondesc[i]["user_custo_field"]}'>"
            if requiredfield == ""
              custodiv += "<option value=''>-</option>"
            end
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
              if @fiche != nil
                custo_field = FicheCustoField.where(:domaine_id => @domaine, :fiche_id => @fiche.id, :ucf_id => jsondesc[i]["user_custo_field"]).first
                if custo_field != nil
                  selected_id = custo_field.field_id
                else
                  selected_id = nil
                end
              end
              listevalues.each do |listevalue|
                if listevalue.id == selected_id
                  custodiv += "<option selected value='#{listevalue.value}|$|#{listevalue.id}'>#{listevalue.value}</option>"
                else
                  custodiv += "<option value='#{listevalue.value}|$|#{listevalue.id}'>#{listevalue.value}</option>"
                end
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
	@selectedproject = selectedproject
	@message, @OK = Commun.set_message(params[:kop])
  end



  def update
    type_fiche_id = params[:type_fiche_id].to_s
    init_type_fiche_id  = params[:init_type_fiche_id].to_s
    fiche_id = params[:fiche_id].to_s
	father_id = params[:father_id].to_s
    fiche  = Fiche.where(:id => fiche_id).first
	if father_id != "" then fiche_father  = Fiche.where(:id => father_id).first else fiche_father = nil end
	if params[:reload] == "1"
		redirect_to controller: 'fiches', action: 'edit', fiche_id:fiche_id
	else
		if @can_manage_cards != 1
			redirect_to controller: 'fiches', action: 'edit', fiche_id:fiche_id
		else
		if type_fiche_id != init_type_fiche_id
		  if fiche != nil
			fiche.type_fiche_id = type_fiche_id
			fiche.save
			histochange = "#{t('type')} : #{TypeFiche.where(:id => type_fiche_id).first.name}\n"
			historise_fiche(fiche, histochange)
			redirect_to controller: 'fiches', action: 'edit', fiche_id:fiche_id
		  else
			redirect_to controller: 'fiches', action: 'edit',  type_fiche_id: type_fiche_id
		  end
		else


		  if fiche == nil
			histochange = ""
			fiche = Fiche.new
			fiche.domaine_id = @domaine
			fiche.type_fiche_id = type_fiche_id
			fiche.name = params[:desc].to_s
			fiche.project_id = @selectedproject
			if params[:cycle].to_s == "-" then fiche.cycle_id = nil else fiche.cycle_id = params[:cycle].to_s end
			fiche.status = params[:status].to_s.split("|$|")[1]
			fiche.status_id = params[:status].to_s.split("|$|")[0]
			fiche.description = params[:resume].to_s
			fiche.user_cre = @username
			fiche.user_maj = @username
			if params[:assigne_a].to_s == "-" then
				fiche.user_assign_id = nil
				fiche.user_assign_name = nil
			else
				fiche.user_assign_id = params[:assigne_a].to_s.split("|$|")[0]
				fiche.user_assign_name = params[:assigne_a].to_s.split("|$|")[1]
			end
			fiche.priority_id = params[:priority].to_s.split("|$|")[0]
			fiche.priority_name = params[:priority].to_s.split("|$|")[1]
			step_id = params[:step_id].to_s
			if step_id != ""
			  run_step_result = RunStepResult.where(:id => step_id).first
			  if run_step_result != nil
				fiche.test_id = run_step_result.test_id
				fiche.proc_id = run_step_result.proc_id
				fiche.action_id = run_step_result.action_id
			  end
			end
			if fiche_father != nil
				fiche.father_id = fiche_father.id
				fiche.lignee_id = fiche_father.lignee_id
				fiche.save
			else
				fiche.save
				fiche.lignee_id = fiche.id
				fiche.save
			end
			tp = TypeFiche.where(:id => type_fiche_id).first
			if tp != nil then type_fiche_name = tp.name else type_fiche_name = "" end
			histochange += "#{t('type')} : #{type_fiche_name}\n"
			c = Cycle.where(:id => fiche.cycle_id).first
			if c != nil then cycle_name = c.name else cycle_name = "" end
			histochange += "#{t('ecr_type_fiche.cycle_assigne')} : #{cycle_name}\n"
			histochange += "#{t('ecr_type_fiche.status')} : #{params[:status].to_s.split("|$|")[1]}\n"
			histochange += "#{t('ecr_type_fiche.assigne_a')} : #{params[:assigne_a].to_s.split("|$|")[1]}\n"
			histochange += "#{t('ecr_type_fiche.priorite')} : #{params[:priority].to_s.split("|$|")[1]}\n"

			params.each do |param|
			  if param.to_s.start_with? "ucf"
				if params[param] != ""
				  fiche_custo_field = FicheCustoField.new
				  fiche_custo_field.domaine_id = @domaine
				  fiche_custo_field.fiche_id = fiche.id
				  fiche_custo_field.ucf_id = param
				  fiche_custo_field.ucf_name = params["name#{param}"]
				  fiche_custo_field.field_id = params[param].to_s.split("|$|")[1].to_s.to_i
				  fiche_custo_field.field_value = params[param].to_s.split("|$|")[0]
				  fiche_custo_field.save
				  histochange += "#{fiche_custo_field.ucf_name} : #{fiche_custo_field.field_value}\n"
				end
			  end
			end
			historise_fiche(fiche, histochange)
			if params["newcomm"].to_s != ""
			  fiche_histo = FicheHisto.new
			  fiche_histo.domaine_id = @domaine
			  fiche_histo.fiche_id = fiche.id
			  fiche_histo.status = fiche.status
			  fiche_histo.comment = params["newcomm"]
			  fiche_histo.user_cre = params["newcommwho"]
			  fiche_histo.save
			end
			if params[:fabs].to_s != ""
				joinfiles = params[:fabs].to_s.split("||")
				joinfiles.each do |joinfile|
					if joinfile.length > 36
					fichedownload = FicheDownload.new
					fichedownload.domaine_id = @domaine
					fichedownload.fiche_id = fiche.id
					fichedownload.name = joinfile[36..joinfile.length-1]
					fichedownload.guid = joinfile[0..35]
					fichedownload.save
					end
				end
			end
			  kop = 1
			  if params[:adp].to_s == "adp"
				idparent = params[:addf]
				kop = 6
				if idparent.to_s != ""
					parent = Fiche.where(:domaine_id => @domaine, :id => idparent).first
					if parent != nil
						fiche.father_id = idparent
						fiche.lignee_id = parent.lignee_id
						fiche.save
						changesonlignee(fiche.id, fiche.lignee_id)
						kop = 1
					end
				end
			  end
			  if params[:delp].to_s == "1" then
					fiche.father_id = nil
					fiche.lignee_id = fiche.id
					fiche.save
					changesonlignee(fiche.id, fiche.id)
			  end

			redirect_to controller: 'fiches', action: 'edit', fiche_id: fiche.id, kop: kop

		  else
			if params[:project_id].to_s != fiche.project_id.to_s
				fiche.lignee_id = fiche.id
				fiche.father_id = nil
			end
			if fiche.lignee_id == nil then fiche.lignee_id = fiche.id end
			maj = false
			histochange = ""
			params.each do |param|
			  if param.to_s.start_with? "ucf"
				if params[param] != ""
				  fiche_custo_field = FicheCustoField.where(:domaine_id => @domaine, :fiche_id => fiche.id, :ucf_id => param).first
				  if fiche_custo_field == nil
					maj = true
					histochange += "#{params["name#{param}"].to_s} : #{params[param].to_s.split("|$|")[0].to_s}\n"
				  else
					if fiche_custo_field.ucf_name != params["name#{param}"].to_s or
						fiche_custo_field.field_id.to_s != params[param].to_s.split("|$|")[1].to_s or
						fiche_custo_field.field_value.to_s != params[param].to_s.split("|$|")[0].to_s
					  maj = true
					  histochange += "#{params["name#{param}"].to_s} : #{params[param].to_s.split("|$|")[0].to_s}\n"
					end
				  end
				end
			  end
			  if param.to_s.start_with? "comment-"
				fiche_histo = FicheHisto.where(:domaine_id => @domaine, :id => param.to_s.split('-')[1]).first
				if fiche_histo != nil
				  if params[param] == ""
					fiche_histo.destroy
				  else
					fiche_histo.comment = params[param]
					fiche_histo.save
				  end
				end
			  end

			  if param.to_s.start_with? "newcomm-"
				  fiche_histo = FicheHisto.new
				  fiche_histo.domaine_id = @domaine
				  fiche_histo.fiche_id = fiche.id
				  fiche_histo.status = fiche.status
				  fiche_histo.comment = params[param]
				  fiche_histo.user_cre = params["newcommwho" + (param.to_s.split("-"))[1]]
				  fiche_histo.save
			  end

			end
			if params[:cycle].to_s == "-" then fiche_cycle_id = nil else fiche_cycle_id = params[:cycle].to_s end
			if maj == true or
				params[:project_id] != fiche.project_id or
				fiche.type_fiche_id.to_s != type_fiche_id or
				fiche.name != params[:desc].to_s or
				fiche.cycle_id.to_s != fiche_cycle_id.to_s or
				fiche.status_id.to_s != params[:status].to_s.split("|$|")[0] or
				fiche.description != params[:resume].to_s or
				fiche.user_assign_id.to_s != params[:assigne_a].to_s.split("|$|")[0] or
				fiche.priority_id.to_s != params[:priority].to_s.split("|$|")[0]

			  if fiche.type_fiche_id.to_s != type_fiche_id then
				tp = TypeFiche.where(:id => type_fiche_id).first
				if tp != nil then type_fiche_name = tp.name else type_fiche_name = "" end
				histochange += "#{t('type')} : #{type_fiche_name}\n"
			  end
			  if fiche.cycle_id.to_s != fiche_cycle_id.to_s  then
				c = Cycle.where(:id => fiche_cycle_id).first
				if c != nil then cycle_name = c.name else cycle_name = "" end
				histochange += "#{t('ecr_type_fiche.cycle_assigne')} : #{cycle_name}\n"
			  end
			  if fiche.status_id.to_s != params[:status].to_s.split("|$|")[0].to_s  then
				histochange += "#{t('ecr_type_fiche.status')} : #{params[:status].to_s.split("|$|")[1]}\n"
			  end
			  if fiche.user_assign_id.to_s != params[:assigne_a].to_s.split("|$|")[0].to_s
				histochange += "#{t('ecr_type_fiche.assigne_a')} : #{params[:assigne_a].to_s.split("|$|")[1]}\n"
			  end
			  if fiche.priority_id.to_s != params[:priority].to_s.split("|$|")[0].to_s
				histochange += "#{t('ecr_type_fiche.priorite')} : #{params[:priority].to_s.split("|$|")[1]}\n"
			  end


			  fiche.domaine_id = @domaine
			  fiche.type_fiche_id = type_fiche_id
			  fiche.name = params[:desc].to_s
			  fiche.project_id = @selectedproject
			  fiche.cycle_id = fiche_cycle_id
			  fiche.status = params[:status].to_s.split("|$|")[1]
			  fiche.status_id = params[:status].to_s.split("|$|")[0]
			  fiche.description = params[:resume].to_s
			  fiche.user_maj = @username
			  if params[:assigne_a].to_s == "-" then
				fiche.user_assign_id = nil
				fiche.user_assign_name = nil
			  else
				fiche.user_assign_id = params[:assigne_a].to_s.split("|$|")[0]
				fiche.user_assign_name = params[:assigne_a].to_s.split("|$|")[1]
			  end
			  fiche.priority_id = params[:priority].to_s.split("|$|")[0]
			  fiche.priority_name = params[:priority].to_s.split("|$|")[1]
			  fiche.project_id = params[:project_id]
			  fiche.save
			  params.each do |param|
				if param.to_s.start_with? "ucf"
				  if params[param] != ""
					fiche_custo_field = FicheCustoField.where(:domaine_id => @domaine, :fiche_id => fiche.id, :ucf_id => param).first
					if fiche_custo_field == nil
					  fiche_custo_field = FicheCustoField.new
					end
					fiche_custo_field.domaine_id = @domaine
					fiche_custo_field.fiche_id = fiche.id
					fiche_custo_field.ucf_id = param
					fiche_custo_field.ucf_name = params["name#{param}"]
					fiche_custo_field.field_id = params[param].to_s.split("|$|")[1].to_s.to_i
					fiche_custo_field.field_value = params[param].to_s.split("|$|")[0]
					fiche_custo_field.save
				  end
				end

			  end

			  historise_fiche(fiche, histochange)
			end
			  kop = 1
			  if params[:adp].to_s == "adp"
				idparent = params[:addf]
				kop = 6
				if idparent.to_s != ""
					parent = Fiche.where(:domaine_id => @domaine, :id => idparent).first
					if parent != nil
						fiche.father_id = idparent
						fiche.lignee_id = parent.lignee_id
						fiche.save
						changesonlignee(fiche.id, fiche.lignee_id)
						kop = 1
					end
				end
				redirect_to controller: 'fiches', action: 'edit', fiche_id:fiche_id, onglet: "parent"
			  else
				  if params[:delp].to_s == "1" then
						fiche.father_id = nil
						fiche.lignee_id = fiche.id
						fiche.save
						changesonlignee(fiche.id, fiche.id)
						redirect_to controller: 'fiches', action: 'edit', fiche_id:fiche_id, onglet: "parent"
					else
						@message, @OK = Commun.set_message(:kop)
						render html: "#{@OK};#{@message}".html_safe
				  end
			  end

		  end

		end
		end
	end
  end


  def changesonlignee(pere, lignee)
	son = Fiche.where(:domaine_id => @domaine, :father_id => pere).first
	if son != nil and @can_manage_cards == 1
		@refresh = true
		son.lignee_id = lignee
		son.save
		changesonlignee(son.id, lignee)
	end
  end

  def move
    ok = t('message.deplacement_impossible')
    if params["moved_fiche"] != nil and @can_manage_cards == 1
      fiche  = Fiche.where(:id => params["moved_fiche"]).first
      if fiche != nil
		majgroup = false
		majstatus = false
		majlignee = false
		histochangegroup = ""
		histochangestatus = ""
		if params["groupid"] != ""
			case params["groupby"]
				when "cycle_id"
					if fiche.cycle_id.to_s != params["groupid"]
						cycle = Cycle.where(:domaine_id => @domaine, :id => params["groupid"]).first
						if cycle != nil
							fiche.cycle_id = cycle.id
							majgroup = true
							histochangegroup = "#{t('ecr_type_fiche.cycle_assigne')} : #{cycle.name}\n"
						end
					end
				when "priority_id"
					if fiche.priority_id.to_s != params["groupid"]
						priority = ListeValue.where(:domaine_id => @domaine, :id => params["groupid"]).first
						if priority != nil
							fiche.priority_id = priority.id
							fiche.priority_name = priority.value
							majgroup = true
							histochangegroup = "#{t('ecr_type_fiche.priorite')} : #{priority.value}\n"
						end
					end
				when "user_assign_id"
					if fiche.user_assign_id.to_s != params["groupid"]
						user = User.where(:domaine_id => @domaine, :id => params["groupid"]).first
						if user != nil
							fiche.user_assign_id = user.id
							fiche.user_assign_name = user.username
							majgroup = true
							histochangegroup = "#{t('ecr_type_fiche.assigne_a')} : #{user.username}\n"
						end
					end
				when "lignee_id"
					if fiche.lignee_id.to_s != params["groupid"]
						lignee = Fiche.where(:domaine_id => @domaine, :id => params["groupid"]).first
						if lignee != nil
							fiche.lignee_id = lignee.id
							fiche.father_id = lignee.id
							majgroup = true
							majlignee = true
						end
					end

			end
		end
        oldstatus_id = fiche.status_id
        status_id = params["new_status"]
        if oldstatus_id.to_s != status_id.to_s
          type_fiche = TypeFiche.where(:id => fiche.type_fiche_id).first
          node_init = Node.where(:domaine_id => @domaine, :sheet_id => type_fiche.sheet_id, :obj_id => oldstatus_id).first
          node_new = Node.where(:domaine_id => @domaine, :sheet_id => type_fiche.sheet_id, :obj_id => status_id).first
          if node_init != nil and node_new != nil
            link = Link.where(:domaine_id => @domaine, :sheet_id => type_fiche.sheet_id, :node_father_id_fk => node_init.id_externe, :node_son_id_fk => node_new.id_externe).first
            if link == nil
              link = Link.where(:domaine_id => @domaine, :sheet_id => type_fiche.sheet_id, :node_father_id_fk => node_new.id_externe, :node_son_id_fk => node_init.id_externe).first
            end
            if link != nil
              ok = "ok"
            else
              ok = t('message.le_nouveau_status_ne_suit_pas_le_workflow')
            end
          else
            ok = t('message.le_nouveau_status_ne_suit_pas_le_workflow')
          end
		  if ok == "ok"
			majstatus = true
			status_name = params["new_status_name"]
            fiche.status = status_name
            fiche.status_id = status_id
            fiche.user_maj = @username
            histochangestatus = "#{t('ecr_type_fiche.status')} : #{status_name}\n"
		  end
        else
          ok = "ok"
        end

		if majstatus or majgroup
            fiche.save
			if majlignee
				changesonlignee(fiche.id, fiche.lignee_id)
				if @refresh != nil and @refresh == true then ok = 'refresh' end
			end
            histochange = histochangestatus + histochangegroup
			if histochange != "" then historise_fiche(fiche, histochange) end
         end

      end
    end
    render html: ok, status: '200'
  end



  def historise_fiche(fiche, histochange)
    if histochange != ""
      fiche_histo = FicheHisto.new
      fiche_histo.domaine_id = @domaine
      fiche_histo.fiche_id = fiche.id
      fiche_histo.status = fiche.status
      fiche_histo.comment = nil
      fiche_histo.user_cre = @username
      fiche_histo.jsondesc = "#{histochange}"
      fiche_histo.save
    end
  end

def uploadfile
	fiche_id = request.headers["fiche"]
	filename = request.headers["filename"]
	guid = SecureRandom.uuid
	newfilename = guid + filename
	newfile = File.open("./public/upload/#{newfilename}", "wb")
	scaled_bytes = request.body.read #.to_blob
	newfile.puts scaled_bytes
	newfile.close

	fiche = Fiche.where(:id => fiche_id).first
	downloadcreated = "0"
	if fiche != nil
		fichedownload = FicheDownload.new
		fichedownload.domaine_id = @domaine
		fichedownload.fiche_id = fiche_id
		fichedownload.name = filename
		fichedownload.guid = guid
		fichedownload.save
		downloadcreated = "1"
	end
	render json: "#{guid}||#{filename}||#{downloadcreated}", status: '200'
end

def deleteupload
	fiche_id = params[:fiche]
	filename = params[:filename]
	fileuploaded = FicheDownload.where("domaine_id = #{@domaine} and fiche_id = #{fiche_id} and guid = '#{filename[0..35]}'").first
	if fileuploaded != nil then fileuploaded.destroy end
	File.delete("./public/upload/#{filename}")
	render json: "", status: '200'
end

def get_fiches_filtered
	filtre = params[:str].to_s
	resultat = ""
	if filtre != ""
		fiches = Fiche.where("domaine_id = #{@domaine} and (id rlike '^#{filtre}' or name like '%#{filtre}%')").limit(50).all
		fiches.each do |fiche|
			resultat += "<option id=\"#{fiche.id}\" value=\"##{fiche.id} #{fiche.name}\">\n"
		end
	end

	render html: resultat.html_safe
end

end
