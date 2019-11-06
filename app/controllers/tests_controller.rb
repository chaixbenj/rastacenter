class TestsController < ApplicationController
  before_action :require_login

  def index
      @atddsteps = (params[:atddsteps] != nil ? params[:atddsteps] : flash[:atddsteps]).to_s
      @popup = (params[:popup] != nil ? params[:popup] : flash[:popup]).to_s
      showtestid = (params[:showtestid] != nil ? params[:showtestid] : flash[:showtestid]).to_s
      @mode = (params[:mode] != nil ? params[:mode] : flash[:mode]).to_s
      majOK = (params[:majOK] != nil ? params[:majOK] : flash[:majOK]).to_s
      rempproc_id = (params[:rempproc_id] != nil ? params[:rempproc_id] : flash[:rempproc_id]).to_s
	  rempatdd_id = (params[:rempatdd_id] != nil ? params[:rempatdd_id] : flash[:rempatdd_id]).to_s
      @rempprocs = (params[:rempprocs] != nil ? params[:rempprocs] : flash[:rempprocs]).to_s
	  @remplatdds = (params[:remplatdds] != nil ? params[:remplatdds] : flash[:remplatdds]).to_s
      @filtrename = (params[:testname] != nil ? params[:testname] : flash[:testname]).to_s
      @filtretype = (params[:testtype] != nil ? params[:testtype] : flash[:testtype]).to_s
      @filtrelevel = (params[:testlevel] != nil ? params[:testlevel] : flash[:testlevel]).to_s
      @filtrestate = (params[:teststate] != nil ? params[:teststate] : flash[:teststate]).to_s
      @filtreproc = (params[:proc_id] != nil ? params[:proc_id] : flash[:proc_id]).to_s
	  @filtreatdd = (params[:fatdd_id] != nil ? params[:fatdd_id] : flash[:fatdd_id]).to_s
      @procs = (params[:procs] != nil ? params[:procs] : flash[:procs])
	  @latdds = (params[:latdds] != nil ? params[:latdds] : flash[:latdds])
      testlist = (params[:testlist] != nil ? params[:testlist] : flash[:testlist])
	  @fiche_id = (params[:fiche_id] != nil ? params[:fiche_id] : flash[:fiche_id])

	  @fiche_name, @linked_fiche_color, @linked_fiche_user = get_fiche(@fiche_id)
      @test, @canmodif_atdd, @ownername = gettestinfo(showtestid)
      if @test != nil or @fiche_id != nil
        @test_states, @test_types, @test_levels = getpropertiestestlists
		if @fiche_id != nil then majOK = "12" end
        @message, @OK = Commun.set_message(majOK)
		if @test != nil
			@linked_fiche_id = @test.fiche_id
			@linked_fiche_name, @linked_fiche_color, @linked_fiche_user = get_fiche(@linked_fiche_id)
		end
      end
      if @mode == "" or @mode == "folder"
			  @htmlrepertoire = buildhtmlrepertoire(@atddsteps).html_safe
      else
        if rempproc_id != "" and rempproc_id != "-" and @locked_project_version == 0
          replaceprocedureintests(@filtreproc, rempproc_id, testlist)
        end
		if rempatdd_id != "" and rempatdd_id != "-" and @locked_project_version == 0
          replacestepatddintests(@filtreatdd, rempatdd_id, testlist)
        end
        @test_states, @test_types, @test_levels = getpropertiestestlists
        @procedures = getprocedures
		@latddsteps = getatddsteps
        @htmlliste = buildhtmllist(@atddsteps, @filtrename, @filtretype, @filtrelevel, @filtrestate, @filtreproc, @filtreatdd).html_safe
      end

  end


  def add_folder
	if @can_manage_public_test == 1 and @locked_project_version == 0
      newFolder = TestFolder.new
      newFolder.test_folder_father_id = params[:folder].to_i
      newFolder.domaine_id = @domaine
      newFolder.project_id = TestFolder.where(:id => params[:folder]).first.project_id
      newFolder.name = t('ecr_test.nouveau_dossier')
      newFolder.can_be_updated = 1
      newFolder.save
      params.each do |lparam|
		if params["#{lparam}"]==nil then param = "#{lparam[0]}" else param = "#{lparam}" end
        flash["#{param}"] = params["#{param}"]
      end
	end
    redirect_to controller: 'tests', action: 'index'
  end

  def addtest

    if @can_manage_public_test == 1 and @locked_project_version == 0
      if params[:atdd_fiche_id].to_s != ""
        fiche = Fiche.where(:id => params[:atdd_fiche_id]).first
        description = fiche.description.to_s
        if (!(description.include? "Scenario:") and !(description.include? "Scenario Outline:")) then
          description = "Scenario:#{params[:atdd_fiche_name]}\n" + description
        end
        description = description.gsub('Scenario:','Scenario:SCENARIO').gsub('Scenario Outline:','Scenario:SCENARIO').gsub("Background:","Scenario:Background:")
        test_type = Liste.select("liste_values.id").joins("INNER JOIN liste_values on  liste_values.domaine_id = listes.domaine_id and liste_values.liste_id = listes.id").where("listes.domaine_id = #{@domaine} and listes.code='TEST_TYPE' and liste_values.value='WEB'").first
        scenarios = description.to_s.split("Scenario:")
        background = ""
        if scenarios.length > 0
          for i in 0..scenarios.length-1
            tscenario = scenarios[i].to_s.split("\r").map(&:strip).delete_if {|x| x == "" }
            if tscenario != nil
              if tscenario[0].to_s.strip == "Background:"
                background = scenarios[i].gsub("Background:","")
              else
                if tscenario[0].to_s.strip.start_with? "SCENARIO"
                  tscenario = scenarios[i].to_s.split("\r")
                  new_test = Test.new
                  new_test.is_valid = 1
                  new_test.test_folder_id = params[:folder].to_i
                  new_test.domaine_id = @domaine
                  new_test.test_type_id = test_type.id
                  new_test.name = (tscenario[0].sub("SCENARIO","").strip == "" ? params[:atdd_fiche_name] : tscenario[0].sub("SCENARIO","").strip)
                  new_test.private = 0
                  new_test.is_atdd =  1
                  new_test.fiche_id = params[:atdd_fiche_id]
                  new_test.owner_user_id = @my_user_id
                  new_test.version_id = @selectedversion
                  new_test.has_real_step = 0
                  new_test.save
                  new_test.current_id = new_test.id
                  new_test.save
                  Fiche.where(:id => params[:atdd_fiche_id]).update_all(:test_id => new_test.id)
                  generate_atdd_steps(background + "\r" + tscenario.drop(1).join("\r"), new_test.id, params[:atdd_fiche_id])
                  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{new_test.id}", :version_id => new_test.version_id, :get => 0).update_all(:get => 1)
                end
              end
            end
          end
        end
      else
        new_test = Test.new
        new_test.is_valid = 1
        new_test.test_folder_id = params[:folder].to_i
        new_test.domaine_id = @domaine
        test_type = Liste.select("liste_values.id").joins("INNER JOIN liste_values on  liste_values.domaine_id = listes.domaine_id and liste_values.liste_id = listes.id").where("listes.domaine_id = #{@domaine} and listes.code='TEST_TYPE' and liste_values.value='WEB'").first
        new_test.test_type_id = test_type.id
        new_test.name = t('ecr_test.nouveau_test')
        new_test.private = 1
        new_test.is_atdd =  0
        new_test.owner_user_id = @my_user_id
        new_test.version_id = @selectedversion
        new_test.has_real_step = 0
        new_test.save
        new_test.current_id = new_test.id
        new_test.save
        ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{new_test.id}", :version_id => new_test.version_id, :get => 0).update_all(:get => 1)
      end
      params.each do |lparam|
		if params["#{lparam}"]==nil then param = "#{lparam[0]}" else param = "#{lparam}" end
        flash["#{param}"] = params["#{param}"]
      end
	  flash[:atdd_fiche_id] = nil
	  flash[:fiche_id] = nil
	end
	redirect_to controller: 'tests', action: 'index'
  end





  def rename
    if @locked_project_version == 0
      what = params[:what].to_s
      foldername = params[:rfoldername].to_s
      folderid = params[:rfolder].to_s
      testname = params[:rtestname].to_s
      testid = params[:rtest].to_s
      case what
      when "folder"
        folder = TestFolder.where(:id => folderid).first
        if folder != nil and foldername != ""
          folder.name = foldername
          folder.save
        end
      when "test"
        test = Test.where(:id => testid).first
        if test != nil and testname != ""
          if test.is_atdd.to_s != "2"
            test.name = testname
            test.user_maj = User.where(:id => @my_user_id).first.username
            test.save
            Node.where(:domaine_id => @domaine, :obj_type => 'testinsuite', :obj_id => test.id).update_all(:name => testname)
            ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
            Node.where(:domaine_id => @domaine, :obj_id => testid, :obj_type => 'testinsuite').update_all(:name => testname)
          else
            test.description, ignore, test.parameters = variabiliseAtddStep(testname)
            test.user_maj = User.where(:id => @my_user_id).first.username
            test.save
            Node.where(:domaine_id => @domaine, :obj_type => 'testinsuite', :obj_id => test.id).update_all(:name => testname)
            ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
            Node.where(:domaine_id => @domaine, :obj_id => testid, :obj_type => 'testinsuite').update_all(:name => testname)
          end
        end
      else
      end
    end
    render html: 'ok', status: '200'
  end

  def delete
    if @locked_project_version == 0
      delwhat = params[:delwhat].to_s
      idtodelete = params[:idtodel].to_s
      retour="ok"
      if delwhat == "folder"
        folder = TestFolder.where(:id => idtodelete).first
        if folder != nil
          folder.destroy
        end
      else
        if delwhat == "test"
          test = Test.where(:id => idtodelete).first
          if test != nil
            if TestStep.where(:atdd_test_id => test.id).first == nil
              testinsuites = Node.where(:domaine_id => @domaine, :obj_type => 'testinsuite', :obj_id => test.id).all
              if testinsuites != nil
                testinsuites.each do |testinsuite|
                  Link.where(:domaine_id => @domaine, :sheet_id => testinsuite.sheet_id, :node_father_id_fk => testinsuite.id_externe).delete_all
                  Link.where(:domaine_id => @domaine, :sheet_id => testinsuite.sheet_id, :node_son_id_fk => testinsuite.id_externe).delete_all
                  testinsuite.destroy
                end
              end
              #TestStep.where(:domaine_id => @domaine, :test_id => test.id).delete_all
              ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)

			  if test.fiche_id != nil  then
				fiches = Fiche.where(:id => test.fiche_id).all
				fiches.each do |fiche|
					other_test_covering_fiche = Test.where("domaine_id = #{@domaine} and fiche_id = #{test.fiche_id} and id != #{test.id}").first
					if other_test_covering_fiche != nil
						fiche.test_id = other_test_covering_fiche.id
						fiche.save
					else
						fiche.test_id = nil
						fiche.save
					end
				end
			  end

              test.destroy
            else
              retour = "#{t('message.suppression_impossible')}"
            end
          end
        end
      end
    end
    render html: retour
  end


  def update
    @message = nil
    majOK = 0
    testid = params[:testid].to_s
    openfolder = params[:openfolder].to_s
    test = Test.where(:id => testid).first
    if test != nil and @locked_project_version == 0
      if params[:testprivate] !=nil
        test.private =  1
      else
        test.private =  0
      end
      if params[:atddupdatable].to_s == "true"
        if params[:atdd] !=nil then test.is_atdd =  1 else test.is_atdd =  0 end
      end
      test.description = params[:testdesc].to_s
      if params[:testtype].to_i != 0 then test.test_type_id = params[:testtype].to_i end
      if params[:testlevel].to_i != 0 then
        test.test_level_id = params[:testlevel].to_i
      end
      if params[:teststate].to_i != 0 then test.test_state_id = params[:teststate].to_i end
      test.user_maj = User.where(:id => @my_user_id).first.username
      test.name = params[:testnamem].to_s
      majOK = 1
      test.save
      ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{test.id}", :version_id => test.version_id, :get => 0).update_all(:get => 1)
    end
    flash[:repdisp] = openfolder
    flash[:showtestid] = testid
    flash[:majOK] = majOK
    flash[:atddsteps] = params[:atddsteps]
	flash[:fiche_id] = params[:fiche_id]
    redirect_to controller: 'tests', action: 'index'
  end


  def edit
      @popup   = (params[:popup] != nil ? params[:popup] : flash[:popup]).to_s
      @modmodif   = (params[:write] != nil ? params[:write] : flash[:write]).to_s
      @test_id = (params[:test_id] != nil ? params[:test_id] : flash[:test_id])
      @sheet_id = (params[:redirect] != nil ? params[:redirect] : (params[:sheet_id] != nil ? params[:sheet_id] : flash[:sheet_id]))
      @idnodetocentre = (params[:idnodetocentre] != nil ? params[:idnodetocentre] : flash[:idnodetocentre]).to_s
      @display = (params[:display] != nil ? params[:display] : flash[:display]).to_s
      @atddsteps = (params[:atddsteps] != nil ? params[:atddsteps] : flash[:atddsteps]).to_s

    @sheet = nil
    @test, @testtype, @test_type, @testLocked, @lockBy, @sheet_id = gettesteditinfo(@test_id, @modmodif, @sheet_id)
    if @test != nil
      @atdd = @test.is_atdd.to_s
      case @atdd
      when "2"
        @atdd_param = @test.parameters
      when "1"
        @configurationvariables, @environnementvariables, @data_set_variables, @testconstantes = Commun.get_variables_and_constantes_names(@domaine, @selectedversion)
      end
      @teststeps = getsteps(@test_id)
      @sheet, @nodes, @links, @loadgraph = getgrapheelement(@sheet_id, @atdd)

      if @atdd != "1"
        @sheets = getallsheets
        if @sheet == nil
          @sheet_id = @sheets.first.sheet_id
          @sheet, @nodes, @links, @loadgraph = getgrapheelement(@sheet_id, @atdd)
        end
      else
        root_atdd_step_folder = TestFolder.where(:domaine_id => @domaine, :test_folder_father_id => nil).first
        @htmlrepertoire = lister_folder(root_atdd_step_folder, "", "divrep-0", 0, 1, "edit").html_safe
      end
    else
      flash[:repdisp] = cookies[:testrepertoiredisplayed]
      flash[:atddsteps] = params[:atddsteps]
      redirect_to controller: 'tests', action: 'index'
    end
  end



  def paste
    majOK = 3
    if @locked_project_version == 0
      whattopaste = params[:test_or_folder_to_paste].to_s.split('|')
      cookies[:test_or_folder_to_paste] = ""
      if whattopaste.length == 3 and params[:folder_id] != nil and TestFolder.where(:id => params[:folder_id]).first != nil
        copycut = whattopaste[0]
        folderortest = whattopaste[1]
        elem_id = whattopaste[2]
        destination = params[:folder_id]

        # copier/coller d'un test
        if folderortest == "test" and copycut == "copy"
          inittest = Test.where(:id => elem_id).first
          if inittest != nil
            newtest = inittest.dup
            newtest.name = inittest.name + "_copy"
            newtest.test_folder_id = destination
            newtest.save
            newtest.current_id = newtest.id
            newtest.save
            ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{newtest.id}", :version_id => newtest.version_id, :get => 0).update_all(:get => 1)
            teststeps = TestStep.where(:domaine_id => @domaine, :test_id => inittest.id).all
            teststeps.each do |teststep|
              newstep = teststep.dup
              newstep.test_id = newtest.id
              newstep.save
            end
            majOK = 1
          end
        end

        # couper/coller d'un test
        if folderortest == "test" and copycut == "cut"
          inittest = Test.where(:id => elem_id).first
          if inittest != nil
            inittest.test_folder_id = destination
            inittest.save
            majOK = 1
          end
        end

        # couper/coller d'un folder
        if folderortest == "folder" and copycut == "cut"
          initfolder = TestFolder.where(:id => elem_id).first
          if initfolder != nil and initfolder.id.to_s != destination.to_s
            initfolder.test_folder_father_id = destination
            initfolder.save
            majOK = 1
          end
        end

        # copier/coller d'un folder
        if folderortest == "folder" and copycut == "copy"
          initfolder = TestFolder.where(:id => elem_id).first
          if initfolder != nil and initfolder.id.to_s != destination.to_s
            dupplicate_all_sons(elem_id, destination, 0, 0)
            majOK = 1
          end
        end


      end
    end
    flash[:majOK] = majOK
    flash[:atddsteps] = params[:atddsteps]
	flash[:fiche_id] = params[:fiche_id]
    redirect_to controller: 'tests', action: 'index'
  end



  def addsubatddfolder
    folder = params[:folder].to_s
    if @locked_project_version == 0
      newFolder = TestFolder.new
      newFolder.test_folder_father_id = folder.to_i
      newFolder.domaine_id = @domaine
      newFolder.project_id = TestFolder.where(:id => folder.to_i).first.project_id
      newFolder.name = t('ecr_test.nouveau_dossier')
      newFolder.can_be_updated = 1
      newFolder.is_atdd = 1
      newFolder.save
      flash[:test_id] = params[:test_id]
      flash[:popup] = params[:popup].to_s
      flash[:write] = params[:write].to_s
      flash[:lock] = params[:lock].to_s
      flash[:atddsteps] = params[:atddsteps]
	  flash[:back_to_id] = params[:back_to_id]
      redirect_to controller: 'tests', action: params[:screen]
    end
  end

  def addatddsteptest
    folder = params[:folder].to_s
    if @locked_project_version == 0
      new_test = Test.new
      new_test.is_valid = 1
      new_test.is_atdd = 2
      new_test.test_type_id = params[:testtype]
      new_test.test_folder_id = folder.to_i
      new_test.domaine_id = @domaine
      new_test.name = "atdd step"
      new_test.description = t('description')
      new_test.owner_user_id = @my_user_id
      new_test.private = 0
      new_test.version_id = @selectedversion
      new_test.has_real_step = 0
      new_test.save
      new_test.current_id = new_test.id
      new_test.save
      if params[:cvtstep].to_s != ""
		      step = TestStep.where(:id =>  params[:cvtstep]).first
      		if step != nil
      			code =  step.code.to_s
      			keyword = ""
      			case code[0..2]
      				when "Giv"
      					keyword = "Given"
      				when "Whe"
      					keyword = "When"
      				when "The"
      					keyword = "Then"
      				when "But"
      					keyword = "But"
      				when "And"
      					keyword = "And"
      			end
			      if keyword != ""
  			      if code.index(keyword + "\n") != nil then code = code.sub(keyword + "\n", "") else code = code.sub(keyword, "") end
              code = code.gsub("\n", " ")
        			new_test.description = code
        			new_test.parameters = variabiliseAtddStep(code)[2]
        			new_test.save
              code = code.gsub("'","''")
              TestStep
                .where("domaine_id = #{@domaine} and temporary = 1 and code REGEXP '^(Given|When|Then|And|But)#{code}$'")
                .update_all("atdd_test_id = #{new_test.id}, temporary = null, type_code = concat('ATDD' , LOWER(SUBSTRING_INDEX(code, ' ', 1))), code = '##{new_test.id}|$|#{code}|$|'")
              tests_using_step = TestStep.select("test_id").where(:atdd_test_id => new_test.id).all
              tests_using_step.each do |test_using_step|
                  updateTestRealSteps(test_using_step.test_id)
              end
            end
          end
       end
      ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{new_test.id}", :version_id => new_test.version_id, :get => 0).update_all(:get => 1)
      flash[:test_id] = params[:test_id]
      flash[:popup] = params[:popup].to_s
      flash[:write] = params[:write].to_s
      flash[:lock] = params[:lock].to_s
      flash[:newstep] = new_test.id
      flash[:atddsteps] = params[:atddsteps]
      flash[:back_to_id] = params[:back_to_id]
      redirect_to controller: 'tests', action: params[:screen]
    end
  end


  def pasteatddelement
    majOK = 3
    if @locked_project_version == 0
      whattopaste = params[:test_or_folder_to_paste].to_s.split('|')
      cookies[:atdd_test_or_folder_to_paste] = ""
      if whattopaste.length == 3 and params[:folder_id] != nil and TestFolder.where(:id => params[:folder_id]).first != nil
        copycut = whattopaste[0]
        folderortest = whattopaste[1]
        elem_id = whattopaste[2]
        destination = params[:folder_id]

        # copier/coller d'un test
        if folderortest == "test" and copycut == "copy"
          inittest = Test.where(:id => elem_id).first
          if inittest != nil
            newtest = inittest.dup
            newtest.name = inittest.name
            newtest.test_folder_id = destination
            newtest.save
            newtest.current_id = newtest.id
            newtest.save
            ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{newtest.id}", :version_id => newtest.version_id, :get => 0).update_all(:get => 1)
            teststeps = TestStep.where(:domaine_id => @domaine, :test_id => inittest.id).all
            teststeps.each do |teststep|
              newstep = teststep.dup
              newstep.test_id = newtest.id
              newstep.save
            end
            majOK = 1
          end
        end

        # couper/coller d'un test
        if folderortest == "test" and copycut == "cut"
          inittest = Test.where(:id => elem_id).first
          if inittest != nil
            inittest.test_folder_id = destination
            inittest.save
            majOK = 1
          end
        end

        # couper/coller d'un folder
        if folderortest == "folder" and copycut == "cut"
          initfolder = TestFolder.where(:id => elem_id).first
          if initfolder != nil and initfolder.id.to_s != destination.to_s
            initfolder.test_folder_father_id = destination
            initfolder.save
            majOK = 1
          end
        end

        # copier/coller d'un folder
        if folderortest == "folder" and copycut == "copy"
          initfolder = TestFolder.where(:id => elem_id).first
          if initfolder != nil and initfolder.id.to_s != destination.to_s
            dupplicate_all_sons(elem_id, destination, 0, 0)
            majOK = 1
          end
        end


      end
    end
    flash[:test_id] = params[:test_id]
    flash[:popup] = params[:popup].to_s
    flash[:write] = params[:write].to_s
    flash[:lock] = params[:lock].to_s
    flash[:atddsteps] = params[:atddsteps]
    redirect_to controller: 'tests', action: params[:screen]
  end


  private


	def gettestinfo(showtestid)
		test = nil
		canmodif_atdd = true
		ownername = ""
		if showtestid.to_s != ""
		  test = Test.where(:id => showtestid).first
		  owner = User.where(:id => test.owner_user_id).first
		  if test != nil
        owner = User.where(:id => test.owner_user_id).first
        if TestStep.where(:domaine_id => @domaine, :test_id => test.id).first != nil
          canmodif_atdd = false
        end
		  end
		  ownername = ""
		  if owner != nil
        ownername = owner.username
		  end

		end
		return test, canmodif_atdd, ownername
	end

  def getpropertiestestlists
		test_states = Liste.select("liste_values.*").joins("INNER JOIN liste_values on  liste_values.domaine_id = listes.domaine_id and liste_values.liste_id = listes.id").where("listes.domaine_id = #{@domaine} and listes.code='TEST_STATE'").all
		test_types = Liste.select("liste_values.*").joins("INNER JOIN liste_values on  liste_values.domaine_id = listes.domaine_id and liste_values.liste_id = listes.id").where("listes.domaine_id = #{@domaine} and listes.code='TEST_TYPE'").all
		test_levels = Liste.select("liste_values.*").joins("INNER JOIN liste_values on  liste_values.domaine_id = listes.domaine_id and liste_values.liste_id = listes.id").where("listes.domaine_id = #{@domaine} and listes.code='TEST_LEVEL'").all
		return test_states, test_types, test_levels
	end

	def buildhtmlrepertoire(atddsteps)
		root_test_folder = TestFolder.where(:domaine_id => @domaine, :test_folder_father_id => nil).first
		htmlrepertoire = ""
		if atddsteps == ""
			htmlrepertoire = lister_folder(root_test_folder, htmlrepertoire, "divrep-0", 0, nil, "index")
		else
			htmlrepertoire = lister_folder(root_test_folder, htmlrepertoire, "divrep-0", 0, 1, "index")
		end
		return htmlrepertoire
	end

	def lister_folder(folder, htmlrepertoire, parent_id, niveau, atdd, screen)
	  if atdd == nil then filtre_atdd = "is_atdd is null" else filtre_atdd = "is_atdd = #{atdd}" end
	  folder_id = folder.id
	  folder_name = folder.name
	  button_add_folder = ""
	  buttonAddTest = ""
	  rename_folder = ""
	  button_cut_folder = ""
	  buttonCopyFolder = ""
	  button_paste = ""
	  buttonMore = ""
	  decalage = 0
	  styledecalage = ""
	  for i in 0..niveau
      decalage += 10
      styledecalage = " style='margin-left:#{decalage}px' "
	  end
	  if @can_manage_test_folder == 1 and @locked_project_version == 0
      if folder.project_id != nil
        button_add_folder = "<button class='btnaddfolder' title='#{t('ecr_test.ajouter_repertoire')}' style='float: right;' onclick='addSubFolder(#{folder_id}, \"#{parent_id}-#{folder_id}\")'></button>"
        buttonCopyFolder = "<button class='btncopy' id='btncopyf#{folder_id}' title='#{t('copier')}' style='float: right;display: none;' onclick='copyFolder(#{folder_id})'></button>"
        buttonMore = "<button class='btnmore' title='#{t('plus_d_options')}' style='float: right;' onclick='morefolderoption(this,#{folder_id});'></button>"
        if folder.can_be_updated == 1
          rename_folder = " onclick='rename_folder(#{folder_id})' "
          button_cut_folder = "<button class='btncut' id='btncutf#{folder_id}' title='#{t('couper')}' style='float: right;display: none;' onclick='cutFolder(#{folder_id})'></button>"
          button_delete_folder = "<button class='btndel' id='btndelf#{folder_id}' title='#{t('supprimer')}' style='float: right;display: none;' onclick='deleteFolder(#{folder_id})'></button>"
        end
      end
	  end
	  if @locked_project_version == 0 and @can_do_something == 1
      buttonAddTest = "<button class='btnaddtest' title='#{t('ecr_test.ajouter_test')}' style='float: right;' onclick='addTest(#{folder_id}, \"#{parent_id}-#{folder_id}\")'></button>"
      button_paste = "<button class='btnpaste' name='btnpaste' style='display: none;float: right;' title='#{t('coller')}' style='float: right;' onclick='pasteelement(#{folder_id})'></button>"
	  end
		if TestFolder.where("domaine_id = #{@domaine} and test_folder_father_id = #{folder_id} and #{filtre_atdd}").first == nil and Test.where(:test_folder_id => folder_id, :version_id => @selectedversion).first == nil #pas d'enfant
      if niveau <=1
        htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span></div>#{buttonMore}#{button_delete_folder}#{buttonAddTest}#{button_add_folder}#{button_cut_folder}#{buttonCopyFolder}#{button_paste}</div></div>"
      else
        htmlrepertoire += "<div class='treegroupmore' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span></div>#{buttonMore}#{button_delete_folder}#{buttonAddTest}#{button_add_folder}#{button_cut_folder}#{buttonCopyFolder}#{button_paste}</div></div>"
      end
    else
      if niveau <=1
        if niveau == 0
          signe = "-&nbsp;&nbsp;"
        else
          signe = "+&nbsp;&nbsp;"
        end
        if folder.test_folder_father_id == nil #root folder
          htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showTestHideSons(\"#{parent_id}-#{folder_id}\")'><b>#{signe}</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span>"
          if atdd == nil
            htmlrepertoire += "<a class='btnmodeliste' style='float:right;' href='../tests/index?mode=liste'  title='#{t('ecr_test.mode_liste')}' onclick='startloader();'></a>"
          else
            if screen != "edit"
              htmlrepertoire += "<a class='btnmodeliste' style='float:right;' href='../tests/index?atddsteps=1&mode=liste'  title='#{t('ecr_test.mode_liste')}' onclick='startloader();'></a>"
            end
          end
          htmlrepertoire += "</div></div>"
        else
          htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showTestHideSons(\"#{parent_id}-#{folder_id}\")'><b>#{signe}</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span></div>#{buttonMore}#{buttonAddTest}#{button_add_folder}#{button_cut_folder}#{buttonCopyFolder}#{button_paste}</div>"
        end
      else
        htmlrepertoire += "<div class='treegroupmore' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showTestHideSons(\"#{parent_id}-#{folder_id}\")'><b>+&nbsp;&nbsp;</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span></div>#{buttonMore}#{buttonAddTest}#{button_add_folder}#{button_cut_folder}#{buttonCopyFolder}#{button_paste}</div>"
      end
      sons = TestFolder.select("test_folders.*")
      .joins("LEFT OUTER JOIN userprojects on userprojects.domaine_id = test_folders.domaine_id and userprojects.project_id = test_folders.project_id")
      .where("test_folders.domaine_id = #{@domaine} and test_folder_father_id = #{folder_id} and (userprojects.user_id = #{@my_user_id} or test_folders.project_id is null) and test_folders.#{filtre_atdd}").order("test_folders.name").all
			sons.each do |son|
				htmlrepertoire = lister_folder(son, htmlrepertoire, "#{parent_id}-#{folder_id}", niveau+1, atdd, screen)
			end

      tests = Test.where("domaine_id = #{@domaine} and test_folder_id = #{folder_id} and version_id = #{@selectedversion} and (owner_user_id=#{@my_user_id} or private=0)").order(:name, :description).all
      tests.each do |test|
 			  alertvide = ""
			  if test.has_real_step == 0
          alertvide = "<span title='empty test' class='circled' style='color:red;float:left; margin-top:0px;margin-right:7px;'>!</span>"
			  end
        if atdd == nil then testname = test.name.to_s.gsub("<","&lt;") else testname = test.description.to_s.gsub("<","&lt;") end
        marqueprivate = ""
        a_valider = ""
        if test.private == 1
          marqueprivate = "<div class='marqueprivate' style='float: left;' title='#{t('prive')}'></div>"
        end
        if test.is_valid == nil or test.is_valid == 0
          a_valider = "style=\"color:red;\" title=\"#{t('a_valider')}\""
        end
        buttonDeltest = "<button class='btndel' id='btndelt#{test.id}' title='#{t('supprimer')}' style='float: right;display: none;' onclick='surligne_selected(\"treetest#{test.id}\", \"treetest\");deleteTest(#{test.id})'></button>"
        buttonCuttest = "<button class='btncut' id='btncutt#{test.id}' title='#{t('couper')}' style='float: right;display: none;' onclick='cutTest(#{test.id});surligne_selected(\"treetest#{test.id}\", \"treetest\");'></button>"
        buttonCopytest = "<button class='btncopy' id='btncopyt#{test.id}' title='#{t('copier')}' style='float: right;display: none;' onclick='copyTest(#{test.id});surligne_selected(\"treetest#{test.id}\", \"treetest\");'></button>"
        buttonMoretest = "<button class='btnmore' title='#{t('plus_d_options')}' style='float: right;' onclick='this.style.display=\"none\";document.getElementById(\"btncopyt#{test.id}\").style.display=\"inline\";document.getElementById(\"btndelt#{test.id}\").style.display=\"inline\";document.getElementById(\"btncutt#{test.id}\").style.display=\"inline\";';></button>"
        if atdd == nil then
          buttonEdit = "<button class='btnedit' title='#{t('editer')}' style='float: right;' onclick='showTest(#{test.id})'></button>"
          buttonATDD = ""
        else
          buttonEdit = ""
          buttonATDD = "<button class='btnedit' title='#{t('editer')}' style='float: right;' onclick='showTest(#{test.id})'></button>"
          if screen == "edit"
            buttonATDD = "<div class='btncode' style='float:right' onclick='window.open(\"../tests/edit?nw=1&test_id=#{test.id}&write=1&load=1&popup=true&atddsteps=1\", \"tests\", \"width=a,height=b\");'></div>"
            buttonATDD += "<span class='circled' title='But' onclick='insertcodeinstr(\"but\", #{test.id})'>B</span><span class='circled' title='And' onclick='insertcodeinstr(\"and\", #{test.id})'>A</span><span class='circled' title='Then' onclick='insertcodeinstr(\"then\",#{test.id})'>T</span><span class='circled' title='When' onclick='insertcodeinstr(\"when\",#{test.id})'>W</span><span class='circled' title='Given' onclick='insertcodeinstr(\"given\",#{test.id})'>G</span>"
          end
        end

        if (@can_manage_public_test == 0 and test.owner_user_id != @my_user_id) or @locked_project_version == 1
          styledecalagetest = " style='margin-left:#{decalage+10}px' "
          htmlrepertoire += "<div class='treegroupmore' name='#{parent_id}-#{folder_id}' id='#{parent_id}-#{folder_id}-test#{test.id}'><input type='hidden' id='hidoltn#{test.id}' value='#{testname.gsub("'","&apos;")}'/><div class='treetest' #{styledecalagetest} id='treetest#{test.id}'>#{alertvide}#{marqueprivate}<div class='treeline' id='spant#{test.id}' ><span #{a_valider}>#{testname}</span></div>#{buttonEdit} #{buttonATDD}</div></div>"
        else
          styledecalagetest = " style='margin-left:#{decalage+10}px' "
          htmlrepertoire += "<div class='treegroupmore' name='#{parent_id}-#{folder_id}' id='#{parent_id}-#{folder_id}-test#{test.id}'><input type='hidden' id='hidoltn#{test.id}' value='#{testname.gsub("'","&apos;")}'/><div class='treetest' #{styledecalagetest} id='treetest#{test.id}'>#{alertvide}#{marqueprivate}<div class='treeline' id='spant#{test.id}' onclick='renameTest(#{test.id})'><span #{a_valider}>#{testname}</span></div>#{buttonMoretest}#{buttonDeltest}#{buttonCuttest}#{buttonCopytest} #{buttonEdit} #{buttonATDD}</button></div></div>"
        end
      end

      htmlrepertoire += "</div>"
	  end
	  return htmlrepertoire
	end

	def replaceprocedureintests(proc_id, rempproc_id, testlists)
		rempproc = Procedure.where(:id => rempproc_id).first
		if rempproc != nil
		  tests = testlists.to_s.split("||")
		  tests.each do |test|
        TestStep.where(:domaine_id => @domaine, :test_id => test.gsub("|","").to_i, :procedure_id => proc_id).update_all(:procedure_id => rempproc_id)
		  end
		end
	end

	def replacestepatddintests(atdd_id, rempatdd_id, testlists)
		rempatdd = Test.where(:id => rempatdd_id).first
		if rempatdd != nil
		  tests = testlists.to_s.split("||")
		  tests.each do |test|
        TestStep.where(:domaine_id => @domaine, :test_id => test.gsub("|","").to_i, :atdd_test_id => atdd_id).update_all(:atdd_test_id => rempatdd_id)
		  end
		end
	end

	def getprocedures
		return Procedure.select("distinct procedures.*, funcandscreens.name as funcname")
    .joins("INNER JOIN funcandscreens on funcandscreens.id = procedures.funcandscreen_id")
    .joins("INNER JOIN nodes on nodes.domaine_id = funcandscreens.domaine_id and nodes.obj_id = funcandscreens.id and nodes.obj_type='funcscreen'")
    .joins("INNER JOIN userprojects on userprojects.domaine_id = funcandscreens.domaine_id and userprojects.project_id = funcandscreens.project_id")
    .where("userprojects.user_id = #{@my_user_id} and procedures.version_id = #{@selectedversion}").order("procedures.name").all
	end

	def getatddsteps
		return Test.select("tests.*")
		  .joins("INNER JOIN test_folders on test_folders.id = tests.test_folder_id")
		  .joins("INNER JOIN userprojects on userprojects.domaine_id = test_folders.domaine_id and userprojects.project_id = test_folders.project_id  and userprojects.user_id = #{@my_user_id} and userprojects.project_id = #{@selectedproject}")
		  .where("tests.is_atdd = 2").order("tests.description").all
	end

	def buildhtmllist(atddsteps, filtrename, filtretype, filtrelevel, filtrestate, filtreproc, filtreatdd)
		htmlliste = ""
		filtre = "tests.domaine_id = #{@domaine} and tests.version_id = #{@selectedversion} and (tests.owner_user_id=#{@my_user_id} or tests.private=0)"
		if filtrename.gsub(" ","") != ""
		  if atddsteps == "1"
        filtre += " and tests.description like '%#{filtrename}%'"
		  else
        filtre += " and tests.name like '%#{filtrename}%'"
		  end
		end
		if filtretype != ""
		  filtre += " and test_type_id = #{filtretype}"
		end
		if filtrelevel != "-" and filtrelevel != ""
		  filtre += " and test_level_id = #{filtrelevel}"
		end
		if filtrestate != "-" and filtrestate != ""
		  filtre += " and test_state_id = #{filtrestate}"
		end
		if atddsteps == "1"
			filtre += " and test_folders.is_atdd = 1 "
		else
			filtre += " and test_folders.is_atdd is null "
		end
		if filtreproc != "-" and filtreproc != ""
		  tests = Test.select("distinct tests.*")
			.joins("INNER JOIN test_folders on test_folders.id = tests.test_folder_id")
			.joins("INNER JOIN userprojects on userprojects.domaine_id = test_folders.domaine_id and userprojects.project_id = test_folders.project_id  and userprojects.user_id = #{@my_user_id} and userprojects.project_id = #{@selectedproject}")
			.joins("INNER JOIN test_steps on tests.domaine_id = test_steps.domaine_id and tests.id = test_steps.test_id and test_steps.procedure_id = #{filtreproc}").where("#{filtre}").order("tests.is_atdd, tests.name, tests.description").all
		  chkbx = true
		else
			if filtreatdd != "-" and filtreatdd != ""
				tests = Test.select("distinct tests.*")
				.joins("INNER JOIN test_folders on test_folders.id = tests.test_folder_id")
				.joins("INNER JOIN userprojects on userprojects.domaine_id = test_folders.domaine_id and userprojects.project_id = test_folders.project_id  and userprojects.user_id = #{@my_user_id} and userprojects.project_id = #{@selectedproject}")
				.joins("INNER JOIN test_steps on tests.domaine_id = test_steps.domaine_id and tests.id = test_steps.test_id and test_steps.atdd_test_id = #{filtreatdd}").where("#{filtre}").order("tests.is_atdd, tests.name, tests.description").all
				chkbx = true
			else
			  tests = Test
			  .joins("INNER JOIN test_folders on test_folders.id = tests.test_folder_id")
			  .joins("INNER JOIN userprojects on userprojects.domaine_id = test_folders.domaine_id and userprojects.project_id = test_folders.project_id  and userprojects.user_id = #{@my_user_id} and userprojects.project_id = #{@selectedproject}")
			  .where("#{filtre}").limit(500).order("tests.is_atdd, tests.name, tests.description").all
			  chkbx = false
			end
		end

		tests.each do |test|
		  alertvide = ""
		  if test.has_real_step == 0
        alertvide = "<span title='empty test' class='circled' style='color:red;float:left; margin-top:0px;margin-right:7px;'>!</span>"
		  end
		  if test.is_atdd.to_s != "2" then testname = test.name else testname = test.description.gsub("<","&lt;") end
		  marqueprivate = ""
		  a_valider = ""
		  if test.private == 1
        marqueprivate = "<div class='marqueprivate' style='float: left;' title='#{t('prive')}'></div>"
		  end
		  if test.is_valid == nil or test.is_valid == 0
        a_valider = "style=\"color:red;\" title=\"#{t('a_valider')}\""
		  end
		  if (@can_manage_public_test == 0 and test.owner_user_id != @my_user_id) or @locked_project_version == 1
        htmlliste += "<div class='treegroup' id='test#{test.id}'><input type='hidden' id='hidoltn#{test.id}' value='#{testname.gsub("'","&apos;")}'/><div class='treetest' >#{marqueprivate}<div class='treeline' id='spant#{test.id}' ><span #{a_valider}>#{test.name}</span></div><button class='btnedit' title='#{t('editer')}' style='float: right;' onclick='showTest(#{test.id})'></button></div></div>"
		  else
        if chkbx
          inputchkbx = "<input style='float: left;' type='checkbox' id='#{test.id}' name='chbxinput' onmousedown='checkShift(event, #{test.id});'/>"
        end
        if test.is_atdd.to_s != "2"
          buttonDeltest = "<button class='btndel' id='btndelt#{test.id}' title='#{t('supprimer')}' style='float: right;display: none;' onclick='surligne_selected(\"treetest#{test.id}\", \"treetest\");deleteTest(#{test.id})'></button>"
          buttonCuttest = "<button class='btncut' id='btncutt#{test.id}' title='#{t('couper')}' style='float: right;display: none;' onclick='cutTest(#{test.id});surligne_selected(\"treetest#{test.id}\", \"treetest\");'></button>"
          buttonCopytest = "<button class='btncopy' id='btncopyt#{test.id}' title='#{t('copier')}' style='float: right;display: none;' onclick='copyTest(#{test.id});surligne_selected(\"treetest#{test.id}\", \"treetest\");'></button>"
          buttonMoretest = "<button class='btnmore' title='#{t('plus_d_options')}' style='float: right;' onclick='this.style.display=\"none\";document.getElementById(\"btncopyt#{test.id}\").style.display=\"inline\";document.getElementById(\"btndelt#{test.id}\").style.display=\"inline\";document.getElementById(\"btncutt#{test.id}\").style.display=\"inline\";';></button>"
          buttonEdit = "<button class='btnedit' title='#{t('editer')}' style='float: right;' onclick='showTest(#{test.id})'>"
        else
          buttonDeltest = "<button class='btndel' id='btndelt#{test.id}' title='#{t('supprimer')}' style='float: right;display: none;' onclick='surligne_selected(\"treetest#{test.id}\", \"treetest\");deleteTest(#{test.id})'></button>"
          buttonCuttest = "<button class='btncut' id='btncutt#{test.id}' title='#{t('couper')}' style='float: right;display: none;' onclick='cutTest(#{test.id});surligne_selected(\"treetest#{test.id}\", \"treetest\");'></button>"
          buttonCopytest = "<button class='btncopy' id='btncopyt#{test.id}' title='#{t('copier')}' style='float: right;display: none;' onclick='copyTest(#{test.id});surligne_selected(\"treetest#{test.id}\", \"treetest\");'></button>"
          buttonMoretest = "<button class='btnmore' title='#{t('plus_d_options')}' style='float: right;' onclick='this.style.display=\"none\";document.getElementById(\"btncopyt#{test.id}\").style.display=\"inline\";document.getElementById(\"btndelt#{test.id}\").style.display=\"inline\";document.getElementById(\"btncutt#{test.id}\").style.display=\"inline\";';></button>"
          buttonEdit = "<button class='btnedit' title='#{t('editer')}' style='float: right;' onclick='showTest(#{test.id})'>"
        end
        htmlliste += "<div class='treegroup' id='test#{test.id}'><input type='hidden' id='hidoltn#{test.id}' value='#{testname.gsub("'","&apos;")}'/><div class='treetest' id='treetest#{test.id}' style='width:100%'>#{inputchkbx}#{marqueprivate}#{alertvide}<div class='treeline' id='spant#{test.id}' onclick='renameTest(#{test.id})'><span #{a_valider}>#{testname}</span></div>#{buttonMoretest}#{buttonDeltest}#{buttonCuttest}#{buttonCopytest}#{buttonEdit}</div></div>"
		  end
		end
		return htmlliste = htmlliste.html_safe
	end


	def gettesteditinfo(showtestid, modmodif, sheet_id)
		test = nil
		testtype = nil
		test_type = nil
		testLocked = nil
		lockBy = nil
		if showtestid.to_s != ""
			test = Test.where(:id => showtestid).first
			testtype = test.test_type_id
			rtest_type = ListeValue.where(:domaine_id => @domaine, :id => test.test_type_id).first
			if rtest_type != nil
				test_type = rtest_type.value
			end
			if ((@can_manage_public_test == 1 and test.private == 0) or test.owner_user_id == @my_user_id) and modmodif != "0" and @locked_project_version == 0
			  is_locked = Lockobject.where("domaine_id = #{@domaine} and obj_id = #{test.id} and obj_type = 'test' and user_id != #{@my_user_id}").first
			  if is_locked != nil and (Time.now - is_locked.created_at)/3600 < 2
          testLocked = true
          lockBy = User.where(:id => is_locked.user_id).first.username
			  else
          testLocked = false
          Lockobject.where("domaine_id = #{@domaine} and obj_id = #{test.id} and obj_type = 'test'").delete_all
          newlock = Lockobject.new
          newlock.domaine_id = @domaine
          newlock.obj_id = test.id
          newlock.obj_type = 'test'
          newlock.user_id = @my_user_id
          newlock.save
          cookies[:objectlocked] = '1'
			  end
			else
			  testLocked = true
			  lockBy = nil
			end
			if sheet_id.to_s == ""
				sheet_id = test.sheet_id
			end
		end
		return test, testtype, test_type, testLocked, lockBy, sheet_id
	end

	def getsteps(test_id)
    return TestStep.select("test_steps.*, tests.description as atdd_code, tests.parameters as atdd_parameters, procedures.name as procname, procedures.parameters as procparam, procedures.return_values as procparamout")
    .joins("LEFT OUTER JOIN procedures on procedures.id = test_steps.procedure_id")
    .joins("LEFT OUTER JOIN tests on tests.id = test_steps.atdd_test_id")
    .where("test_steps.domaine_id = #{@domaine} and test_id = #{test_id}").all.order(:sequence)
	end

	def getgrapheelement(sheet_id, atdd)
	  sheet = nodes = links = loadgraph = nil
	  if sheet_id.to_s != "" and atdd != "1"
      sheet = Sheet.where(:id => sheet_id).first
      nodes = Node.select("nodes.*, sheets.private as private, sheets.owner_user_id as owner")
      .joins("LEFT OUTER JOIN sheets on nodes.obj_id = sheets.id and nodes.obj_type='conceptionsheet'").where("nodes.domaine_id = #{@domaine} and nodes.sheet_id = #{sheet_id}").all
      links = Link.where(:domaine_id => @domaine, :sheet_id => sheet_id).all
      loadgraph = true
	  end
	  return sheet, nodes, links, loadgraph
	end

	def getallsheets
		return Sheet.select("sheets.id as sheet_id, projects.name as project_name, sheets.name as sheet_name")
	  .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
	  .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id and userprojects.user_id = #{@my_user_id}")
	  .joins("INNER JOIN projects on projects.id = sheet_folders.project_id")
	  .where("sheets.domaine_id=#{@domaine} and sheets.version_id = #{@selectedversion} and sheets.type_sheet='conception_sheet' and (sheets.private=0 or  sheets.owner_user_id = #{@my_user_id})")
	  .order("projects.name, sheets.name").all
	end

	def dupplicate_all_sons(folderinit, folderdest, level, duprootid)
	  level += 1
	  initfolder = TestFolder.where(:id => folderinit).first
	  if initfolder != nil
			newfolder = initfolder.dup
			newfolder.test_folder_father_id = folderdest
			newfolder.can_be_updated = 1
			newfolder.save
			if level == 1
				duprootid = newfolder.id
			end
	  end
	  alltests = Test.where(:domaine_id => @domaine, :test_folder_id => folderinit).all
	  alltests.each do |inittest|
      newtest = inittest.dup
      newtest.name = inittest.name + "_copy"
      newtest.test_folder_id = newfolder.id
      newtest.save
      newtest.current_id = newtest.id
      newtest.save
      ComputerLastGet.where(:domaine_id => @domaine, :object_type => "Test#{newtest.id}", :version_id => newtest.version_id, :get => 0).update_all(:get => 1)
      teststeps = TestStep.where(:domaine_id => @domaine, :test_id => inittest.id).all
		  teststeps.each do |teststep|
        newstep = teststep.dup
        newstep.test_id = newtest.id
        newstep.save
		  end
	  end
	  allsonfolders = TestFolder.where(:domaine_id => @domaine, :test_folder_father_id => folderinit).all
	  allsonfolders.each do |sonfolder|
      if sonfolder.id != duprootid
        dupplicate_all_sons(sonfolder.id, newfolder.id, level, duprootid)
      end
	  end
	end

	def get_fiche(fiche_id)
		if fiche_id.to_s != "" then
			fiche = Fiche.where(:id => fiche_id).first
			if fiche != nil then
				return fiche.name, TypeFiche.where(:id => fiche.type_fiche_id).first.color, fiche.user_assign_name
			else
				return nil
			end
		else
			return nil
		end

	end


	def generate_atdd_steps(scenario, test_id, fiche_id)
		spec = scenario.split("\r")
		sequence = 1
		keyword = ""
		addnew=true
		test_step = nil
		keyword = ""
    hasTemporaryStep = false
		spec.each do |step|
		step = step.strip
			if step.start_with?("Given") then
				keyword = "Given"
				addnew=true
			elsif step.start_with?("When") then
				keyword = "When"
				addnew=true
			elsif step.start_with?("Then") then
				keyword = "Then"
				addnew=true
			elsif step.start_with?("But") then
				keyword = "But"
				addnew=true
			elsif step.start_with?("And") then
				keyword = "And"
				addnew=true
      elsif step.start_with?("Examples:") then
        keyword = "Array"
				addnew=true
			end
			if step.sub(keyword,"").strip != "" or keyword=="Array"
				if addnew then
          variabiliseAtddStep = variabiliseAtddStep(step)
          createTemporaryStep = true
            if keyword != "Array" then
              test_existant = Test.where(:domaine_id => @domaine, :is_atdd => 2, :description => variabiliseAtddStep[0][keyword.length..-1]).select("tests.id, tests.description").joins("INNER JOIN test_steps on test_steps.atdd_test_id=tests.id").first
                if test_existant != nil && test_existant.description.strip.length == variabiliseAtddStep[0][keyword.length..-1].strip.length then
                    test_step_existant = TestStep.where(:atdd_test_id => test_existant.id).first
                    if test_step_existant != nil then
                      test_step = test_step_existant.dup
                      test_step.test_id = test_id
                      test_step.parameters = variabiliseAtddStep[1]
                      test_step.sequence = sequence
                      sequence += 1
                      test_step.save
                      createTemporaryStep = false
                    end
                end
            end
            if createTemporaryStep then
    					test_step = TestStep.new
    					test_step.domaine_id = @domaine
    					test_step.test_id = test_id
    					test_step.sequence = sequence
    					sequence += 1
    					test_step.code = variabiliseAtddStep[0]
              if keyword != "Array"
					hasTemporaryStep = true
					test_step.parameters = variabiliseAtddStep[1]
    					    test_step.type_code = "TmpATDD" + keyword[0..1]
    					    test_step.temporary = 1
              else
                test_step.type_code = "ATDDarray"
                test_step.temporary = nil
              end
    					test_step.save
          end
				else
					test_step.code = test_step.code + "\n" + step
					test_step.save
				end
				addnew=false
			end
		end
    if hasTemporaryStep == false then
      Test.where(:id => test_id).update_all(:has_real_step => 1)
    end
	end



  def variabiliseAtddStep(path)
	path = path.gsub(/\"arg(\d+)\"/, "\"atddargstr\"")
	path = path.gsub(/arg(\d+)/, "\"atddargnum\"")
	arguments = path.scan(/\"([^\"]*)\"|(\d+)/)
    arguments_name = ""
    arguments_value = ""
    arguments_string = ""
    if arguments!=nil && arguments.length>0
        for i in 0..arguments.length-1
            arguments_name += "arg#{i.to_s}|$|"
            arguments_value += (arguments[i][0]==nil ? arguments[i][1] : arguments[i][0]) + "|$|"
        end
        path = path.gsub(/(\d+)/, "atddargnum")
		path = path.gsub(/\"([^\"]*)\"/, "atddargstr")
		arguments = path.scan(/atddarg.../)
		for i in 0..arguments.length-1
			if arguments[i]=="atddargnum" then 
				path = path.sub(/atddarg.../, "arg#{i.to_s}")
			else 
				path = path.sub(/atddarg.../, "\"arg#{i.to_s}\"")
			end
        end
		
    end
    return path, arguments_value, arguments_name
  end

  def updateTestRealSteps(test_id)
    temporaryStep = TestStep.where(:domaine_id => @domaine, :test_id => test_id, :temporary => 1).first
    if temporaryStep == nil then Test.where(:id => test_id).update_all(:has_real_step => 1) end
  end

end
