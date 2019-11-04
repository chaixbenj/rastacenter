class SheetsController < ApplicationController
  before_action :require_login

  def index
	@mode = (params[:mode] != nil ? params[:mode] : flash[:mode]).to_s
    @sheettype = (params[:sheettype] != nil ? params[:sheettype] : flash[:sheettype]).to_s
    @sname = (params[:snames] != nil ? params[:snames] : flash[:snames]).to_s
    shid = (params[:shid] != nil ? params[:shid] : flash[:shid]).to_s
    test_id = (params[:test_id] != nil ? params[:test_id] : flash[:test_id]).to_s
    @testnamefiltre = (params[:tests] != nil ? params[:tests] : flash[:tests]).to_s
    ko = (params[:ko] != nil ? params[:ko] : flash[:ko]).to_s

		if @sheettype == ""
		  @sheettype = cookies[:sheettype].to_s
		end

    @can_manage = set_sheet_auth(@sheettype)

		if @mode == "" or @mode == "folder"
      @htmlrepertoire = buildhtmlrepertoire(@sheettype).html_safe
		else
		  if @sheettype == 'test_suite'
        @tests = get_tests
		  end
		  sheets = get_sheets(test_id)
		  @htmlliste = buildhtmlliste(sheets).html_safe
		end
    @sheet, @ownername = get_sheet_info(shid)
    @message, @OK = Commun.set_message(ko)
  end

  def add_folder
    new_folder = SheetFolder.new
    new_folder.sheet_folder_father_id = params[:folder].to_i
    new_folder.domaine_id = @domaine
    new_folder.project_id = SheetFolder.where(:id => params[:folder].to_i).first.project_id
    new_folder.name = t('ecr_test.nouveau_dossier')
    new_folder.can_be_updated = 1
    new_folder.type_sheet = params[:sheettype]
    new_folder.save
	  flash[:sheettype] = params[:sheettype]
	  flash[:mode] = params[:mode]
	  redirect_to controller: 'sheets', action: 'index'
  end

  def add_sheet
    sheettype = params[:sheettype]
    if (@locked_project_version == 0 or sheettype == 'workflow')
      new_sheet = Sheet.new
      new_sheet.domaine_id = @domaine
      new_sheet.user_cre = @my_user_id
      new_sheet.sheet_folder_id = params[:folder].to_i
      new_sheet.name = t("ecr_#{sheettype}.nouveau_sheet")
      new_sheet.owner_user_id = @my_user_id
      if sheettype == 'workflow'
        new_sheet.private = 0
        new_sheet.version_id = @currentversion
      else
        new_sheet.private = 1
        new_sheet.version_id = @selectedversion
      end
      new_sheet.type_sheet = sheettype
      new_sheet.save
      new_sheet.current_id = new_sheet.id
      new_sheet.save
      if sheettype == 'test_suite'
        startnode = Node.new
        startnode.domaine_id = @domaine
        startnode.sheet_id = new_sheet.id
        startnode.id_externe = 1
        startnode.x = 1
        startnode.y = 1
        startnode.name = t('debut')
        startnode.type_node = 'card'
        startnode.obj_type = 'starttestsuite'
        startnode.obj_id = nil
        startnode.save
      end
      if sheettype == 'workflow'
        startnode = Node.new
        startnode.domaine_id = @domaine
        startnode.sheet_id = new_sheet.id
        startnode.id_externe = 1
        startnode.x = 1
        startnode.y = 1
        startnode.name = t('debut')
        startnode.type_node = 'card'
        startnode.obj_type = 'startworkflow'
        startnode.obj_id = nil
        startnode.save
      end
    end
    flash[:shid] = new_sheet.id
    flash[:sheettype] = sheettype
    flash[:mode] = params[:mode]
    redirect_to controller: 'sheets', action: 'index'
  end

  def update
    sheettype = params[:sheettype]
    mode = params[:mode].to_s
    shid = params[:shid].to_s

    if params[:valid] != nil
      sheet = Sheet.where(:id => shid).first
      flash[:ko] = 1
      if sheet != nil
        sheet.name = params[:sname].to_s
        if params[:sprivate].to_s  == ""
          sheet.private = 0
        else
          sheet.private = 1
        end
        sheet.description =   params[:sdesc].to_s
        sheet.save
        flash[:shid] = sheet.id
        flash[:sheettype] = sheettype
        flash[:mode] = mode
      end
    end
		redirect_to controller: 'sheets', action: 'index'
  end

  def edit
    @popup = (params[:popup] != nil ? params[:popup] : flash[:popup])
    @fromrun = (params[:fromrun] != nil ? params[:fromrun] : flash[:fromrun])
    @sheettype = (params[:sheettype] != nil ? params[:sheettype] : flash[:sheettype]).to_s
    redir_sheet_id   = (params[:redirect]!= nil ? params[:redirect] : flash[:redirect]).to_s
    @modmodif   = (params[:write].to_s!= nil ? params[:write] : flash[:write]).to_s
    @campain   = (params[:campain]!= nil ? params[:campain] : flash[:campain])
    sheetinit = (params[:sheetinit]!= nil ? params[:sheetinit] : flash[:sheetinit]).to_s
    sheet_encours = (params[:sheet_id]!= nil ? params[:sheet_id] : flash[:sheet_id]).to_s
    @back_to_id = (params[:back_to_id]!= nil ? params[:back_to_id] : (flash[:back_to_id]!= nil ? flash[:back_to_id] : "shid=#{sheet_encours}"))

    has_been_redirected = false
    if redir_sheet_id != "" or sheet_encours == ""
      if redir_sheet_id != ""
        @sheet = Sheet.select("sheets.*, sheet_folders.project_id as project_id").joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id").where("sheets.id = #{redir_sheet_id}").first
        if @sheet != nil
          if Userproject.where(:user_id => @my_user_id, :project_id => @sheet.project_id).first != nil and (@sheet.private == 0 or @sheet.owner_user_id == @my_user_id)
            sheet_encours = redir_sheet_id
          else
            has_been_redirected = true
            flash[:sheet_id] = sheetinit
            flash[:redirect] = nil
            flash[:popup] = @popup
            flash[:fromrun] = @fromrun
            flash[:sheettype] = @sheettype
            flash[:write] = @modmodif
            flash[:campain] = @campain
            redirect_to controller: 'sheets', action: 'edit'
          end
        else
          has_been_redirected = true
          redirect_to controller: "sheets", action: "index"
        end
      else
        has_been_redirected = true
        redirect_to controller: "sheets", action: "index"
      end
    end

    if has_been_redirected == false
      case  @sheettype
      when 'conception_sheet'
        @can_manage = @can_manage_public_conception_sheet
        if @modmodif == '0'
          @campains = get_campains_covering_scheme(sheet_encours)
        end
      when  'test_suite'
        @can_manage = @can_manage_public_test_suite
      when 'workflow'
        @can_manage = @can_manage_worflows_and_card
        @status = get_workflow_status
      else
      end

      @sheet, @sheetLocked, @lockBy = get_sheet_and_put_lock(sheet_encours, @sheettype, @modmodif)
      if @campain == nil or @campain == ""
        @nodes = get_nodes(sheet_encours, @sheettype)
      else
        @nodes = get_nodes_with_campain_result(sheet_encours, @sheettype, @campain)
      end
      @links = Link.where(:domaine_id => @domaine, :sheet_id => sheet_encours).all

      case  @sheettype
      when 'conception_sheet'
        @sheets = get_conception_sheets
        @existingFunc, @existingFuncNotLinked = Commun.get_func_and_screens(@selectedversion, @domaine, @my_user_id, "")
        render "sheets/editconceptionsheet"
      when  'test_suite'
        @htmltestrepertoire = buildtestrephtml.html_safe
        render "sheets/edittestsuite"
      when 'workflow'
        render "sheets/editworkflow"
      else
      end
    end
  end


  def updatediag
    @sheettype = params[:sheettype]
    modmodif   = params[:write].to_s

    case  @sheettype
    when 'conception_sheet'
      @can_manage = @can_manage_public_conception_sheet
    when  'test_suite'
      @can_manage = @can_manage_public_test_suite
    when 'workflow'
      @can_manage = @can_manage_worflows_and_card
    else
    end

    mysheet, is_my_sheet_locked, lock_by = get_sheet_and_put_lock(params[:sheet_id], @sheettype, modmodif)

    if params[:dodiag] != nil and is_my_sheet_locked == false
      sheet_id        = params[:sheet_id].to_s
      project_id      = params[:project_id].to_s
      action          = params[:dodiag].to_s
      obj             = params[:obj].to_s
      ext_id          = params[:idext].to_s
      node_type       = params[:nodetype].to_s
      obj_type        = params[:objtype].to_s
      linked_obj_id   = params[:linkedobj].to_s
      x               = params[:x].to_i
      y               = params[:y].to_i
      father          = params[:father].to_s
      son             = params[:son].to_s
      title           = params[:title].to_s
      inflexion_x     = params[:inflexion_x].to_i
      inflexion_y     = params[:inflexion_y].to_i
      curved          = params[:curved].to_s
			newthread       = params[:newthread].to_s
			waitlink       = params[:waitlink].to_s

      case action
      when "merge"
        if obj == "node"
          node = Node.where(:domaine_id => @domaine, :sheet_id => sheet_id, :id_externe => ext_id).first
          if node != nil
            node.x != x or node.y = y or node.name.gsub("\n\n","\n").strip != title.gsub("\n\n","\n").strip
            node.x = x
            node.y = y
            node.new_thread = newthread
            node.name = title.gsub("\n\n","\n").strip
            if @sheettype == 'workflow'
              node.obj_type = obj_type
              if linked_obj_id != "" then node.obj_id = linked_obj_id end
            end
            node.save
            if obj_type == "funcscreen"
              if linked_obj_id == ""
                linked_obj_id = node.obj_id
              end
              funcandscreen =Funcandscreen.where(:id => linked_obj_id).first
              if funcandscreen != nil
                if funcandscreen.name.gsub("\n\n","\n").strip != title.gsub("\n\n","\n").strip
                  funcandscreen.name = title.gsub("\n\n","\n").strip
                  funcandscreen.save
                end
              end
            end
          else
            node = Node.new
            node.domaine_id = @domaine
            node.sheet_id = sheet_id
            node.id_externe = ext_id
            node.type_node = node_type
            node.x = x
            node.y = y
            node.name = title.gsub("\n\n","\n").strip
            node.obj_type = obj_type
            case obj_type
            when "funcscreen"
              funcandscreen =Funcandscreen.where(:id => linked_obj_id).first
              if funcandscreen == nil
                funcandscreen = Funcandscreen.new
                funcandscreen.domaine_id = @domaine
                funcandscreen.project_id = project_id
                funcandscreen.name = title.gsub("\n\n","\n").strip
                funcandscreen.save
                node.obj_id = funcandscreen.id
              else
                if funcandscreen.name != title
                  funcandscreen.name = title
                  funcandscreen.save
                end
                node.obj_id = linked_obj_id
              end

            when "conceptionsheet"
              if Sheet.where(:id => linked_obj_id).first != nil
                node.obj_id = linked_obj_id
              end

            when "testinsuite"
              if Test.where(:id => linked_obj_id).first != nil
                node.obj_id = linked_obj_id
                node.new_thread = newthread
              end
            end
            node.save
          end
        end
        if father != ""
          link = Link.where(:domaine_id => @domaine, :sheet_id => sheet_id, :node_father_id_fk => father, :node_son_id_fk => son).first
          if link != nil
            link.node_father_id_fk = father
            link.node_son_id_fk = son
            link.inflexion_x = inflexion_x
            link.inflexion_y = inflexion_y
            if curved.to_s != ""
              link.curved = curved
            end

          else
            link = Link.new
            link.domaine_id = @domaine
            link.sheet_id = sheet_id
            link.id_externe = 'link_p'+father+'_f'+son + '_'
            link.node_father_id_fk = father
            link.node_son_id_fk = son
            link.inflexion_x = inflexion_x
            link.inflexion_y = inflexion_y
            if waitlink == nil then waitlink = 0 end
            link.wait_link = waitlink
            if curved.to_s != ""
              link.curved = curved
            end
          end
          link.save
        end

      when "delete"
        if obj == "link"
          Link.where(:domaine_id => @domaine, :sheet_id => sheet_id, :id_externe => ext_id).first.destroy
        else
          if obj == "node"
            deleted_node = Node.where(:domaine_id => @domaine, :sheet_id => sheet_id, :id_externe => ext_id).first
            if deleted_node!=nil and deleted_node.type_node == "line"
              hauteur = father
              Node.where("domaine_id = #{@domaine} and sheet_id = #{sheet_id} and y > #{deleted_node.y}").update_all("y = y - #{hauteur}")
            end
            if deleted_node!=nil and deleted_node.obj_type == "funcscreen"
              funcscreen = Funcandscreen.where(:id => deleted_node.obj_id).first
              domelement = Domelement.where(:domaine_id => @domaine, :funcandscreen_id => funcscreen.id).first
              procedure = Procedure.where(:domaine_id => @domaine, :funcandscreen_id => funcscreen.id).first
              if domelement == nil and procedure == nil then funcscreen.destroy end
            end
            TestStep.where(:domaine_id => @domaine, :sheet_id => sheet_id, :ext_node_id => ext_id).update_all("ext_node_id = null")
            Node.where(:domaine_id => @domaine, :sheet_id => sheet_id, :id_externe => ext_id).first.destroy
            Link.where(:domaine_id => @domaine, :sheet_id => sheet_id, :node_father_id_fk => ext_id).delete_all
            Link.where(:domaine_id => @domaine, :sheet_id => sheet_id, :node_son_id_fk => ext_id).delete_all
          end
        end
      end
    end
    render html: 'ok', status: '200'
  end

  def rename
		if @locked_project_version == 0
      what = params[:what].to_s
      foldername = params[:rfoldername].to_s
      folderid = params[:rfolder].to_s
      sheetname = params[:rsheetname].to_s
      sheetid = params[:rsheet].to_s
      if what == "folder"
        folder = SheetFolder.where(:id => folderid).first
        if folder != nil and foldername != ""
          folder.name = foldername
          folder.save
        end
      end
      if what == "sheet"
        sheet = Sheet.where(:id => sheetid).first
        if sheet != nil and sheetname != ""
          sheet.name = sheetname
          sheet.user_maj = User.where(:id => @my_user_id).first.username
          sheet.save
        end
      end
    end
    render html: 'ok', status: '200'
  end

  def delete
		if @locked_project_version == 0
      delwhat = params[:delwhat].to_s
      idtodelete = params[:idtodel].to_s
      if delwhat == "folder"
        folder = SheetFolder.where(:id => idtodelete).first
        if folder != nil
          folder.destroy
        end
      else
        if delwhat == "sheet"
          sheet = Sheet.where(:id => idtodelete).first
          if sheet != nil
            Test.where(:domaine_id => @domaine, :sheet_id => sheet.id).update_all("sheet_id = null")
            TestStep.where(:domaine_id => @domaine, :sheet_id => sheet.id).update_all("sheet_id = null")
            sheet.destroy
          end
        end
      end
    end
    render html: 'ok', status: '200'
  end

  def paste
		if @locked_project_version == 0
      flash[:ok] = 3
      flash[:sheettype] = params[:sheettype]
      flash[:mode] = params[:mode]
      whattopaste = params["sheet_or_folder_to_paste"].to_s.split('|')
      cookies["sheet_or_folder_to_paste"] = ""
      if whattopaste.length == 3 and params[:folder_id] != nil and SheetFolder.where(:id => params[:folder_id]).first != nil
        project_id = SheetFolder.where(:id => params[:folder_id]).first.project_id
        copycut = whattopaste[0]
        folderorsheet = whattopaste[1]
        elem_id = whattopaste[2]
        destination = params[:folder_id]

        # copier/coller d'un sheet
        if folderorsheet == "sheet" and copycut == "duplicate"
          initsheet = Sheet.where(:id => elem_id).first
          nodes = Node.where(:domaine_id => initsheet.domaine_id, :sheet_id => initsheet.id).all
          links = Link.where(:domaine_id => initsheet.domaine_id, :sheet_id => initsheet.id).all
          if initsheet != nil
            newsheet = initsheet.dup
            newsheet.name = initsheet.name + "_copy"
            newsheet.sheet_folder_id = destination
            newsheet.save
            newsheet.current_id = newsheet.id
            newsheet.save
            flash[:shid] = newsheet.id
            links.each do |link|
              newLink = link.dup
              newLink.sheet_id = newsheet.id
              newLink.save
            end
            nodes.each do |node|
              oldid = node.id
              new_node = node.dup
              new_node.sheet_id = newsheet.id
              new_node.save
              newid = new_node.id
              forcedconfigs = NodeForcedConfig.where(:domaine_id => @domaine, :node_id => oldid).all
              if forcedconfigs != nil
                forcedconfigs.each do |forcedconfig|
                  newforcedconfig = forcedconfig.dup
                  newforcedconfig.node_id = newid
                  newforcedconfig.save
                end
              end
              forcedcomputer = NodeForcedComputer.where(:domaine_id => @domaine, :node_id => oldid).first
              if forcedcomputer != nil
                newforcedcomputer = forcedcomputer.dup
                newforcedcomputer.node_id = newid
                newforcedcomputer.save
              end
              if node.obj_type == "funcscreen"
                duplicate_func_and_screens(node.obj_id, new_node, project_id)
              end
            end
            flash[:ok] = 0
          end
        end

       # copier/coller d'un sheet
        if folderorsheet == "sheet" and copycut == "copy"
          initsheet = Sheet.where(:id => elem_id).first
          nodes = Node.where(:domaine_id => initsheet.domaine_id, :sheet_id => initsheet.id).all
          links = Link.where(:domaine_id => initsheet.domaine_id, :sheet_id => initsheet.id).all
          if initsheet != nil
            newsheet = initsheet.dup
            newsheet.name = initsheet.name + "_copy"
            newsheet.sheet_folder_id = destination
            newsheet.save
            newsheet.current_id = newsheet.id
            newsheet.save
            flash[:shid] = newsheet.id
            links.each do |link|
              newLink = link.dup
              newLink.sheet_id = newsheet.id
              newLink.save
            end
            nodes.each do |node|
              oldid = node.id
              new_node = node.dup
              new_node.sheet_id = newsheet.id
              new_node.save
              newid = new_node.id
              forcedconfigs = NodeForcedConfig.where(:domaine_id => @domaine, :node_id => oldid).all
              if forcedconfigs != nil
                forcedconfigs.each do |forcedconfig|
                  newforcedconfig = forcedconfig.dup
                  newforcedconfig.node_id = newid
                  newforcedconfig.save
                end
              end
              forcedcomputer = NodeForcedComputer.where(:domaine_id => @domaine, :node_id => oldid).first
              if forcedcomputer != nil
                newforcedcomputer = forcedcomputer.dup
                newforcedcomputer.node_id = newid
                newforcedcomputer.save
              end
            end
            flash[:ok] = 0
          end
        end


        # couper/coller d'un sheet
        if folderorsheet == "sheet" and copycut == "cut"
          initsheet = Sheet.where(:id => elem_id).first
          if initsheet != nil
            initsheet.sheet_folder_id = destination
            initsheet.save
            flash[:shid] = initsheet.id
            flash[:ok] = 0
          end
        end

        # couper/coller d'un folder
        if folderorsheet == "folder" and copycut == "cut"
          initfolder = SheetFolder.where(:id => elem_id).first
          if initfolder != nil and initfolder.id.to_s != destination.to_s
            initfolder.sheet_folder_father_id = destination
            initfolder.save
            flash[:ok] = 0
          end
        end

      end
    end
    redirect_to controller: 'sheets', action: 'index'
  end

	def holdunhold
		sheet_id        = params[:sheet_id].to_s
		ext_id          = params[:idext].to_s
		hold      		= params[:hold].to_s
		node = Node.where(:domaine_id => @domaine, :sheet_id => sheet_id, :id_externe => ext_id).first
		if node != nil
			if hold == "true"
				node.hold = 1
			else
				node.hold = nil
			end
			node.save
		end
	  render html: 'ok', status: '200'
	end


  private

  def buildhtmlrepertoire(sheettype)
    root_sheet_folder = SheetFolder.where(:domaine_id => @domaine, :sheet_folder_father_id => nil).first
    return lister_folder(root_sheet_folder, "",  "divrep-0", 0, sheettype)
  end

  def lister_folder(folder, htmlrepertoire, parent_id, niveau, type_sheet)
    folder_id = folder.id
    folder_name = folder.name
    decalage = ""
    button_add_folder = ""
    button_add_sheet = ""
    rename_folder = ""
    button_cut_folder = ""
    button_paste = ""
    decalage = 0
    styledecalage = ""
    button_delete_folder = ""
	buttonDuplicateSheet = ""
    for i in 0..niveau
      decalage += 10
			styledecalage = " style='margin-left:#{decalage}px' "
    end
    if @can_manage == 1 and @locked_project_version == 0
      if folder.project_id != nil
        button_add_folder = "<button class='btnaddfolder' title='#{t('ecr_sheet.ajouter_repertoire')}' style='float: right;' onclick='addSubSheetFolder(#{folder_id}, \"#{parent_id}-#{folder_id}\", \"#{type_sheet}\")'></button>"
        if folder.can_be_updated == 1
          rename_folder = " onclick='renameSheetFolder(#{folder_id})' "
          button_cut_folder = "<button class='btncut' id='btncutf#{folder_id}' title='#{t('couper')}' style='float: right;' onclick='cutSheetFolder(#{folder_id}, \"#{type_sheet}\")'></button>"
          button_delete_folder = "<button class='btndel' id='btndelf#{folder_id}' title='#{t('supprimer')}' style='float: right;' onclick='deleteSheetFolder(#{folder_id})'></button>"
        end
      end
    end
    titleadd_sheet = t('ecr_' + type_sheet + '.ajouter_sheet')
    if @locked_project_version == 0 and @can_do_something == 1
      button_add_sheet = "<button class='btnaddtest' title='#{titleadd_sheet}' style='float: right;' onclick='addSheet(#{folder_id}, \"#{parent_id}-#{folder_id}\", \"#{type_sheet}\")'></button>"
      button_paste = "<button class='btnpaste' name='btnpaste' style='display: none;float: right;' title='#{t('coller')}' style='float: right;' onclick='pastesheetelement(#{folder_id}, \"#{type_sheet}\")'></button>"
    end
    if SheetFolder.where("domaine_id = #{@domaine} and sheet_folder_father_id = #{folder_id}").first == nil and Sheet.where(:domaine_id => @domaine, :sheet_folder_id => folder_id, :version_id => @selectedversion).first == nil #pas d'enfant
      if niveau <=1
        htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span></div>#{button_delete_folder}#{button_add_sheet}#{button_add_folder}#{button_cut_folder}#{button_paste}</div></div>"
      else
        htmlrepertoire += "<div class='treegroupmore' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span></div>#{button_delete_folder}#{button_add_sheet}#{button_add_folder}#{button_cut_folder}#{button_paste}</div></div>"
      end
    else
      if niveau <=1
        if niveau == 0
          signe = "-&nbsp;&nbsp;"
        else
          signe = "+&nbsp;&nbsp;"
        end
        if folder.sheet_folder_father_id == nil and type_sheet != 'workflow' #root folder
          htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showSheetHideSons(\"#{parent_id}-#{folder_id}\", \"#{type_sheet}\")'><b>#{signe}</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span><a class='btnmodeliste' style='float:right;' href='../sheets/index?rd=1&mode=liste&sheettype=#{type_sheet}'  title='#{t('ecr_test.mode_liste')}' onclick='startloader();'></a></div>#{button_add_folder}</div>"
        else
          if type_sheet == 'workflow'
            if @can_manage_worflows_and_card == 0 then button_add_sheet = "" end
            htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showSheetHideSons(\"#{parent_id}-#{folder_id}\", \"#{type_sheet}\")'></span>&nbsp;<div class='treeline' id='span#{folder_id}' ><span>#{t('menu.workflow')}</span></div>#{button_add_sheet}#{button_paste}</div>"
          else
            htmlrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showSheetHideSons(\"#{parent_id}-#{folder_id}\", \"#{type_sheet}\")'><b>#{signe}</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span></div>#{button_add_sheet}#{button_add_folder}#{button_cut_folder}#{button_paste}</div>"
          end
        end
      else
        htmlrepertoire += "<div class='treegroupmore' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><input type='hidden' id='hidoln#{folder_id}' value='#{folder_name}'/><div class='treerep' #{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showSheetHideSons(\"#{parent_id}-#{folder_id}\", \"#{type_sheet}\")'><b>+&nbsp;&nbsp;</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' #{rename_folder}><span>#{folder_name}</span></div>#{button_add_sheet}#{button_add_folder}#{button_cut_folder}#{button_paste}</div>"
      end
      sons = SheetFolder.select("sheet_folders.*")
      .joins("LEFT OUTER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id")
      .where("sheet_folders.domaine_id = #{@domaine} and sheet_folder_father_id = #{folder_id} and type_sheet='#{type_sheet}' and userprojects.user_id = #{@my_user_id}").order("sheet_folders.name").all
      sons.each do |son|
        htmlrepertoire = lister_folder(son, htmlrepertoire, "#{parent_id}-#{folder_id}", niveau+1, type_sheet)
      end
      sheets = Sheet.where("domaine_id = #{@domaine} and sheet_folder_id = #{folder_id} and version_id = #{@selectedversion} and (owner_user_id=#{@my_user_id} or private=0) and type_sheet = '#{type_sheet}'").order(:name).all
      sheets.each do |sheet|
        marqueprivate = ""
        if sheet.private == 1
          marqueprivate = "<div class='marqueprivate' style='float: left;' title='#{t('prive')}'></div>"
        end
        if type_sheet != 'workflow'
          buttonDelSheet = "<button class='btndel' id='btndelt#{sheet.id}' title='#{t('supprimer')}' style='float: right;display: none;' onclick='deleteSheet(#{sheet.id})'></button>"
          buttonCutSheet = "<button class='btncut' id='btncutt#{sheet.id}' title='#{t('couper')}' style='float: right;display: none;' onclick='cutSheet(#{sheet.id}, \"#{type_sheet}\")'></button>"
          buttonCopySheet = "<button class='btncopy' id='btncopyt#{sheet.id}' title='#{t('copier')}' style='float: right;display: none;' onclick='copySheet(#{sheet.id}, \"#{type_sheet}\")'></button>"
          if type_sheet == 'conception_sheet'
			buttonDuplicateSheet = "<button class='btndup' id='btndupt#{sheet.id}' title='#{t('duppliquer')}' style='float: right;display: none;' onclick='duplicateSheet(#{sheet.id}, \"#{type_sheet}\")'></button>"
			buttonMoreSheet = "<button class='btnmore' title='#{t('plus_d_options')}' style='float: right;' onclick='this.style.display=\"none\";document.getElementById(\"btndupt#{sheet.id}\").style.display=\"inline\";document.getElementById(\"btncopyt#{sheet.id}\").style.display=\"inline\";document.getElementById(\"btndelt#{sheet.id}\").style.display=\"inline\";document.getElementById(\"btncutt#{sheet.id}\").style.display=\"inline\";';></button>"
		  else
			buttonMoreSheet = "<button class='btnmore' title='#{t('plus_d_options')}' style='float: right;' onclick='this.style.display=\"none\";document.getElementById(\"btncopyt#{sheet.id}\").style.display=\"inline\";document.getElementById(\"btndelt#{sheet.id}\").style.display=\"inline\";document.getElementById(\"btncutt#{sheet.id}\").style.display=\"inline\";';></button>"
		  end
          divclass = "treegroupmore"
        else
          buttonDelSheet = "<button class='btndel' id='btndelt#{sheet.id}' title='#{t('supprimer')}' style='float: right;' onclick='deleteSheet(#{sheet.id})'></button>"
          buttonCopySheet = "<button class='btncopy' id='btncopyt#{sheet.id}' title='#{t('copier')}' style='float: right;' onclick='copySheet(#{sheet.id}, \"#{type_sheet}\")'></button>"
          divclass = "treegroup"
        end
        if (@can_manage == 0 and sheet.owner_user_id != @my_user_id) or @locked_project_version == 1
          styledecalagetest = " style='margin-left:#{decalage+10}px' "
          htmlrepertoire += "<div class='#{divclass}' name='#{parent_id}-#{folder_id}' id='#{parent_id}-#{folder_id}-sheet#{sheet.id}'><input type='hidden' id='hidoltn#{sheet.id}' value='#{sheet.name.gsub("'","&apos;")}'/><div class='treetest' #{styledecalagetest} id='treesheet#{sheet.id}'>#{marqueprivate}<div class='treeline' id='spant#{sheet.id}' ><span>#{sheet.name}</span></div><button class='btnedit' title='#{t('editer')}' style='float: right;' onclick='showSheet(#{sheet.id})'></button></div></div>"
        else
          styledecalagetest = " style='margin-left:#{decalage+10}px' "
          htmlrepertoire += "<div class='#{divclass}' name='#{parent_id}-#{folder_id}' id='#{parent_id}-#{folder_id}-sheet#{sheet.id}'><input type='hidden' id='hidoltn#{sheet.id}' value='#{sheet.name.gsub("'","&apos;")}'/><div class='treetest' #{styledecalagetest} id='treesheet#{sheet.id}'>#{marqueprivate}<div class='treeline' id='spant#{sheet.id}' onclick='renameSheet(#{sheet.id})'><span>#{sheet.name}</span></div>#{buttonMoreSheet}#{buttonDelSheet}#{buttonCutSheet}#{buttonCopySheet}#{buttonDuplicateSheet}<button class='btnedit' title='#{t('editer')}' style='float: right;' onclick='showSheet(#{sheet.id})'></button></div></div>"
        end
      end
      htmlrepertoire += "</div>"
    end
    return htmlrepertoire
  end

  def get_tests
    return Test.where("tests.domaine_id = #{@domaine} and tests.version_id = #{@selectedversion} and (tests.owner_user_id=#{@my_user_id} or tests.private=0)").order("name").all
  end

  def get_sheets(test_id)
    if @sname != ""
      if test_id != "" and test_id != "-"
        @filtretest = test_id
        sheets = Sheet.select("distinct sheets.*")
        .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
        .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id  and userprojects.project_id = #{@selectedproject}")
        .joins("INNER JOIN nodes on nodes.domaine_id = sheets.domaine_id and nodes.sheet_id = sheets.id and nodes.obj_id = #{test_id}")
        .where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@selectedversion} and userprojects.user_id=#{@my_user_id}  and sheets.name like '%#{@sname}%' and sheets.type_sheet='#{@sheettype}' and (sheets.private=0 or  sheets.owner_user_id = #{@my_user_id})").order(:name).all
      else
        sheets = Sheet.select("distinct sheets.*")
        .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
        .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id  and userprojects.project_id = #{@selectedproject}")
        .where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@selectedversion} and userprojects.user_id=#{@my_user_id}  and sheets.name like '%#{@sname}%' and sheets.type_sheet='#{@sheettype}' and (sheets.private=0 or  sheets.owner_user_id = #{@my_user_id})").order(:name).all
      end
    else
      if test_id != "" and test_id != "-"
        @filtretest = test_id
        sheets = Sheet.select("distinct sheets.*")
        .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
        .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id  and userprojects.project_id = #{@selectedproject}")
        .joins("INNER JOIN nodes on nodes.domaine_id = sheets.domaine_id and nodes.sheet_id = sheets.id and nodes.obj_id = #{test_id}")
        .where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@selectedversion} and userprojects.user_id=#{@my_user_id}  and sheets.type_sheet='#{@sheettype}' and (sheets.private=0 or  sheets.owner_user_id = #{@my_user_id})").limit(500).order(:name).all
      else
        sheets = Sheet.select("distinct sheets.*")
        .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
        .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id  and userprojects.project_id = #{@selectedproject}")
        .where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@selectedversion} and userprojects.user_id=#{@my_user_id}  and sheets.type_sheet='#{@sheettype}' and (sheets.private=0 or  sheets.owner_user_id = #{@my_user_id})").limit(500).order(:name).all
      end
    end
    return sheets
  end

  def buildhtmlliste(sheets)
    htmlliste = ""
    sheets.each do |sheet|
      marqueprivate = ""
      if sheet.private == 1
        marqueprivate = "<div class='marqueprivate' style='float: left;' title='#{t('prive')}'></div>"
      end
      if (@can_manage == 0 and sheet.owner_user_id != @my_user_id) or @locked_project_version == 1
        htmlliste += "<div class='treegroup' id='sheet#{sheet.id}'><input type='hidden' id='hidoltn#{sheet.id}' value='#{sheet.name.gsub("'","&apos;")}'/><div class='treetest' id='treesheet#{sheet.id}' style='width:100%'>#{marqueprivate}<div class='treeline' id='spant#{sheet.id}' ><span>#{sheet.name}</span></div><button class='btnedit' title='#{t('editer')}' style='float: right;' onclick='showSheet(#{sheet.id})'></button></div></div>"
      else
        buttonDelsheet = "<button class='btndel' id='btndelt#{sheet.id}' title='#{t('supprimer')}' style='float: right;display: none;' onclick='surligne_selected(\"treesheet#{sheet.id}\", \"treetest\");deleteSheet(#{sheet.id})'></button>"
        buttonCutsheet = "<button class='btncut' id='btncutt#{sheet.id}' title='#{t('couper')}' style='float: right;display: none;' onclick='cutSheet(#{sheet.id}, \"#{@sheettype}\");surligne_selected(\"treesheet#{sheet.id}\", \"treetest\");'></button>"
        buttonCopysheet = "<button class='btncopy' id='btncopyt#{sheet.id}' title='#{t('copier')}' style='float: right;display: none;' onclick='copySheet(#{sheet.id}, \"#{@sheettype}\");surligne_selected(\"treesheet#{sheet.id}\", \"treetest\");'></button>"
        buttonMore = "<button class='btnmore' title='#{t('plus_d_options')}' style='float: right;' onclick='this.style.display=\"none\";document.getElementById(\"btncopyt#{sheet.id}\").style.display=\"inline\";document.getElementById(\"btndelt#{sheet.id}\").style.display=\"inline\";document.getElementById(\"btncutt#{sheet.id}\").style.display=\"inline\";';></button>"
        htmlliste += "<div class='treegroup' id='test#{sheet.id}'><input type='hidden' id='hidoltn#{sheet.id}' value='#{sheet.name.gsub("'","&apos;")}'/><div class='treetest' id='treesheet#{sheet.id}' style='width:100%'>#{marqueprivate}<div class='treeline' id='spant#{sheet.id}' onclick='renameSheet(#{sheet.id})'><span>#{sheet.name}</span></div>#{buttonMore}#{buttonDelsheet}#{buttonCutsheet}#{buttonCopysheet}<button class='btnedit' title='#{t('editer')}' style='float: right;' onclick='showSheet(#{sheet.id})'></button></div></div>"
      end
    end
    return htmlliste
  end


  def get_sheet_info(shid)
    sheet = ownername = nil
    if shid != nil
		  sheet = Sheet.where(:id => shid).first
		  if sheet != nil and User.where(:id => sheet.owner_user_id).first != nil
			ownername = User.where(:id => sheet.owner_user_id).first.username
		  end
    end
    return sheet, ownername
  end

  def set_sheet_auth(sheettype)
    can_manage = nil
    case  sheettype
    when 'conception_sheet'
      can_manage = @can_manage_public_conception_sheet
    when  'test_suite'
      can_manage = @can_manage_public_test_suite
    when 'workflow'
      can_manage = @can_manage_worflows_and_card
    else
		end
    return can_manage
  end

  def get_campains_covering_scheme(sheet_encours)
    return Sheet.select("distinct campains.id, campains.name, campains.created_at")
    .joins("INNER JOIN nodes on nodes.domaine_id = sheets.domaine_id and nodes.sheet_id = sheets.id and nodes.obj_type='funcscreen'")
    .joins("INNER JOIN funcandscreens on funcandscreens.domaine_id = nodes.domaine_id and funcandscreens.id = nodes.obj_id")
    .joins("INNER JOIN procedures on procedures.domaine_id = nodes.domaine_id and procedures.funcandscreen_id = funcandscreens.id")
    .joins("INNER JOIN run_step_results on run_step_results.domaine_id = nodes.domaine_id and run_step_results.proc_id = procedures.id")
    .joins("INNER JOIN runs on runs.domaine_id = nodes.domaine_id and runs.id = run_step_results.run_id")
    .joins("INNER JOIN campains on campains.domaine_id = nodes.domaine_id and campains.id = runs.campain_id")
    .where("sheets.id = #{sheet_encours} ").all.order("campains.created_at DESC")
  end

  def get_workflow_status
    return Liste.select("liste_values.*")
    .joins("INNER JOIN liste_values on listes.domaine_id = liste_values.domaine_id and listes.id = liste_values.liste_id")
    .where("listes.domaine_id = #{@domaine} and listes.code ='WKF_STATUS'")
    .all.order("liste_values.value")
  end

  def buildtestrephtml
    root_test_folder = TestFolder.where(:domaine_id => @domaine, :test_folder_father_id => nil).first
    htmltestrepertoire = lister_test_folder(root_test_folder, "",  "divrep-0", 0)
    return htmltestrepertoire
  end

  def lister_test_folder(folder, htmltestrepertoire, parent_id, niveau)
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
        htmltestrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><div class='treerep' #{styledecalage}><div class='treeline' id='span#{folder_id}' ><span>#{folder_name}</span></div></div></div>"
      else
        htmltestrepertoire += "<div class='treegroupmore' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><div class='treerep' #{styledecalage}><div class='treeline' id='span#{folder_id}' ><span>#{folder_name}</span></div></div></div>"
      end
    else
      if niveau <=1
        if niveau == 0
          signe = "-&nbsp;&nbsp;"
        else
          signe = "+&nbsp;&nbsp;"
        end
        htmltestrepertoire += "<div class='treegroup' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><div class='treerep'#{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showTestInSuiteHideSons(\"#{parent_id}-#{folder_id}\")'><b>#{signe}</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' ><span>#{folder_name}</span></div></div>"
      else
        htmltestrepertoire += "<div class='treegroupmore' name='#{parent_id}' id='#{parent_id}-#{folder_id}'><div class='treerep'#{styledecalage}><span id=\"signe#{parent_id}-#{folder_id}\"  onclick='showTestInSuiteHideSons(\"#{parent_id}-#{folder_id}\")'><b>+&nbsp;&nbsp;</b></span>&nbsp;<div class='treeline' id='span#{folder_id}' ><span>#{folder_name}</span></div></div>"
      end
      sons = TestFolder.select("test_folders.*").joins("LEFT OUTER JOIN userprojects on userprojects.domaine_id = test_folders.domaine_id and userprojects.project_id = test_folders.project_id").where("test_folders.domaine_id = #{@domaine} and test_folder_father_id = #{folder_id} and userprojects.user_id = #{@my_user_id} and  test_folders.is_atdd is null").order("test_folders.name").all
      sons.each do |son|
        htmltestrepertoire = lister_test_folder(son, htmltestrepertoire, "#{parent_id}-#{folder_id}", niveau+1)
      end
      tests = Test.where("domaine_id = #{@domaine} and test_folder_id = #{folder_id} and version_id = #{@selectedversion} and (owner_user_id=#{@my_user_id} or private=0) and test_type_id is not null").order(:name).all
      tests.each do |test|
        marqueprivate = ""
        if test.private == 1
          marqueprivate = "<div class='marqueprivate' style='float: left;' title='#{t('prive')}'></div>"
        end
				styledecalagetest = " style='margin-left:#{decalage+10}px' "
        htmltestrepertoire += "<div class='treegroupmore' name='#{parent_id}-#{folder_id}' id='#{parent_id}-#{folder_id}-test#{test.id}'><div id='treetest#{test.id}' class='treetest' #{styledecalagetest} name='testitem' onclick='selecttesttoaddsuite(this, #{test.id}, \"#{test.name.gsub("'", "\\'")}\", \"#{test.test_type_id}\")'>#{marqueprivate}<div class='treeline' id='spant#{test.id}' ><span>#{test.name}</span></div></div></div>"
      end
      htmltestrepertoire += "</div>"
    end
    return htmltestrepertoire
  end


  def get_sheet_and_put_lock(sheet_id, sheettype, modmodif)
    sheet = Sheet.select("sheets.*, sheet_folders.project_id as project_id").joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id").where(:id => sheet_id).first
    sheet_locked = lock_by = nil
    if sheet != nil
      if ((@can_manage == 1 and sheet.private == 0) or sheet.owner_user_id == @my_user_id) and modmodif != "0" and @locked_project_version == 0
        @selectedproject = sheet.project_id
        is_locked = Lockobject.where("domaine_id = #{sheet.domaine_id} and obj_id = #{sheet.id} and obj_type = '#{sheettype}' and user_id != #{@my_user_id}").first
        if is_locked != nil and (Time.now - is_locked.created_at)/3600 < 2
          sheet_locked = true
          lock_by = User.where(:id => is_locked.user_id).first.username
        else
          sheet_locked = false
          Lockobject.where("domaine_id = #{sheet.domaine_id} and obj_id = #{sheet.id} and obj_type = 'sheettype'").delete_all
          newlock = Lockobject.new
          newlock.domaine_id = @domaine
          newlock.obj_id = sheet.id
          newlock.obj_type = sheettype
          newlock.user_id = @my_user_id
          newlock.save
          cookies[:objectlocked] = '1'
        end
      else
        sheet_locked = true
        lock_by = nil
      end
    end
    return sheet, sheet_locked, lock_by
  end

  def get_nodes(sheet_encours, sheettype)
    if sheettype == 'test_suite'
      nodes = Node.select("nodes.*, tests.test_type_id as test_type")
      .joins("LEFT JOIN tests on tests.id = nodes.obj_id and nodes.obj_type='testinsuite'")
      .where("nodes.domaine_id = #{@domaine} and nodes.sheet_id = #{sheet_encours} ").all
    else
      nodes = Node.select("nodes.*, sheets.private as private, sheets.owner_user_id as owner, null as test_type")
      .joins("LEFT JOIN sheets on sheets.id = nodes.obj_id and nodes.obj_type='#{sheettype}'").where("nodes.domaine_id = #{@domaine} and nodes.sheet_id = #{sheet_encours} ").all
    end
    return nodes
  end

  def get_nodes_with_campain_result(sheet_encours, sheettype, campain)
    run = Run.where(:domaine_id => @domaine, :campain_id => campain).first
    version = @selectedversion
    if run != nil then version = run.version_id   end
    return Node.select("nodes.id, nodes.domaine_id, nodes.sheet_id, nodes.id_externe, nodes.x, nodes.y, nodes.name, nodes.type_node, nodes.obj_type, nodes.obj_id, nodes.forced, nodes.force_type, sheets.private as private, sheets.owner_user_id as owner,
					count(distinct case when cmpn.cpproc_id is null then procedures.id else null end) as nboutrun,
					count(distinct case when cmpn.cpproc_id is not null and run_step_results.id is null then procedures.id else null end) as nbprocnorun,
					count(distinct case when run_step_results.id is not null and run_step_results.result like 'PASS%' then run_step_results.proc_id else null end) as nbprocpass,
					count(distinct case when run_step_results.id is not null and run_step_results.result like 'FAIL%' then run_step_results.proc_id else null end) as nbprocfail")
    .joins("LEFT JOIN sheets on sheets.id = nodes.obj_id and nodes.obj_type='#{sheettype}'")
    .joins("LEFT JOIN funcandscreens on funcandscreens.domaine_id = nodes.domaine_id and funcandscreens.id = nodes.obj_id and nodes.obj_type='funcscreen'")
    .joins("LEFT JOIN procedures on procedures.domaine_id = nodes.domaine_id and procedures.funcandscreen_id = funcandscreens.id  and procedures.version_id = #{version}")
    .joins("LEFT JOIN (
	select case when test_steps.procedure_id is not null then test_steps.procedure_id else atdd_steps.procedure_id end as cpproc_id
					from
					campain_test_suites
					JOIN nodes as tests on campain_test_suites.domaine_id = tests.domaine_id and campain_test_suites.sheet_id = tests.sheet_id and tests.obj_type = 'testinsuite'
					JOIN test_steps on test_steps.domaine_id = tests.domaine_id and test_steps.test_id = tests.obj_id
					LEFT JOIN test_steps as atdd_steps on atdd_steps.domaine_id = test_steps.domaine_id and atdd_steps.test_id = test_steps.atdd_test_id
					where campain_test_suites.domaine_id = #{@domaine}
					and campain_test_suites.campain_id = #{campain}
					and campain_test_suites.domaine_id = tests.domaine_id
					and campain_test_suites.sheet_id = tests.sheet_id
					and tests.domaine_id = test_steps.domaine_id
					and tests.obj_type = 'testinsuite'
					and tests.obj_id = test_steps.test_id
					and (test_steps.procedure_id is not null or test_steps.atdd_test_id is not null)
					)
	as cmpn on cmpn.cpproc_id = procedures.id  or cmpn.cpproc_id = procedures.current_id")
    .joins("LEFT JOIN run_step_results on run_step_results.domaine_id = nodes.domaine_id and (run_step_results.proc_id = procedures.id or run_step_results.proc_id = procedures.current_id)
				  and run_step_results.steplevel = 'procedure'
				  and run_step_results.run_id in (select id from runs where runs.domaine_id = nodes.domaine_id and runs.campain_id = #{campain})")
    .where("nodes.domaine_id = #{@domaine} and nodes.sheet_id = #{sheet_encours}")
    .all.group("nodes.id, nodes.domaine_id, nodes.sheet_id, nodes.id_externe, nodes.x, nodes.y, nodes.name, nodes.type_node, nodes.obj_type, nodes.obj_id, nodes.forced, nodes.force_type, sheets.private, sheets.owner_user_id")
  end


  def get_conception_sheets
    return Sheet.select("sheets.id as sheet_id, projects.name as project_name, sheets.name as sheet_name")
    .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
    .joins("INNER JOIN userprojects on userprojects.domaine_id = sheet_folders.domaine_id and userprojects.project_id = sheet_folders.project_id and userprojects.user_id = #{@my_user_id}")
    .joins("INNER JOIN projects on projects.id = sheet_folders.project_id").where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@selectedversion} and sheets.type_sheet='conception_sheet' and (sheets.private=0 or  sheets.owner_user_id = #{@my_user_id})").order("projects.name, sheets.name").all
  end


  def duplicate_func_and_screens(node_obj_id, newnode, project_id)
    funcandscreen = Funcandscreen.where(:id => node_obj_id).first
    if funcandscreen != nil
      newfuncscreen = funcandscreen.dup
      newfuncscreen.project_id = project_id
      newfuncscreen.save
      newnode.obj_id = newfuncscreen.id
      newnode.save
      oldids = []
      newids =[]
      domelements = Domelement.where(:domaine_id => @domaine, :funcandscreen_id => funcandscreen.id, :version_id => @selectedversion).all
      domelements.each do |domelement|
        new_domelement = domelement.dup
        new_domelement.funcandscreen_id = newfuncscreen.id
        new_domelement.save
        new_domelement.current_id = new_domelement.id
        new_domelement.save
        oldids << domelement.id
        newids << new_domelement.id
      end
      procedures = Procedure.where(:domaine_id => @domaine, :funcandscreen_id => funcandscreen.id, :version_id => @selectedversion).all
      procedures.each do |procedure|
        new_procedure = procedure.dup
        new_procedure.funcandscreen_id = newfuncscreen.id
        for i in 0..oldids.length-1
          new_procedure.code = new_procedure.code.gsub("$domelement#{oldids[i]}_","$domelement#{newids[i]}_")
        end
        new_procedure.save
        new_procedure.current_id = new_procedure.id
        new_procedure.save
        procedureactions = ProcedureAction.where(:domaine_id => @domaine, :procedure_id => procedure.id).all
        procedureactions.each do |procedureaction|
          newprocedureaction = procedureaction.dup
          newprocedureaction.procedure_id = new_procedure.id
          newprocedureaction.save
        end
      end
    end

  end
end
