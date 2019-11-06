class KanbansController < ApplicationController
  before_action :require_login

  
  def index	
    kanban_id = (params[:kanban_id] != nil ? params[:kanban_id] : (flash[:kanban_id] != nil ? flash[:kanban_id] : cookies[:kanban_id])).to_s
    @mode = (params[:m] != nil ? params[:m] : (flash[:m] != nil ? flash[:m] : cookies[:m])).to_s
    @groupby = (params[:kbgrpby] != nil ? params[:kbgrpby] : (flash[:kbgrpby] != nil ? flash[:kbgrpby] : cookies[:kbgrpby])).to_s
	@linked_id = params[:linked_id]
	if params[:reload].to_s == "1" then params[:filter] = "" end
    if @groupby == "" then @groupby = "id" end
    cookies[:kanban_id] = kanban_id
    cookies[:m] = @mode
    cookies[:kbgrpby] = @groupby
    @message = nil
	
    if params[:delete] != nil
      kanban = Kanban.where(:id => kanban_id).first
      if kanban != nil then kanban.destroy end
    else
      #update massif
      if params[:filter] != nil and params[:filter] == "updt" and params[:massids] != ""
        massive_update(params)
      end
      #sauvegarde d'un filtre
      if params[:saveas] != nil
        if params[:filtreid].to_s == "-1" or params[:filtreid].to_s == ""
          kanban = Kanban.new
          kanban.name =  params[:newkanbanname]
          kanban.father_id = params[:kanbaninitfilter]
          kanban.domaine_id = @domaine
          kanban.is_active = 1
          if params[:private].to_s == "on" then kanban.private = 1 else kanban.private = 0 end
          kanban.owner_user_id = @my_user_id
          kanban.save
          kanban_id = kanban.id
        else
          kanban = Kanban.where(:id => kanban_id).first
          if params[:private].to_s == "on" then kanban.private = 1 else kanban.private = 0 end
          kanban.save
        end
        save_filters(kanban_id, params)
      end
  
     
      if kanban_id != ""
        @kanban = Kanban.where(:id => kanban_id).first
		if @kanban != nil
        #récupération des filtres
        if  params[:filter] != nil then @kanban_tempo_filters = settemporaryfilter(params) end
        if @kanban.father_id == nil 
          @type_fiches, @kanban_statuses, @all_priorities, @all_cycles, @all_users, @bloc_custo, @bloc_custo_updt = get_filters_lists_and_build_html_custo_fields(kanban_id) 
        else 
          if  params[:filter] == nil
            @kanban_filters = KanbanFilter.where(:domaine_id => @domaine, :kanban_id => kanban_id).order("field_name, field_value, value_id").all
          end
          kanban_id = @kanban.father_id
          @type_fiches, @kanban_statuses, @all_priorities, @all_cycles, @all_users, @bloc_custo, @bloc_custo_updt = get_filters_lists_and_build_html_custo_fields(@kanban.father_id) 
        end
       
        #construction de la string pour la clause where du select en fonction des filtres et des champs custo
        if @kanban_filters != nil and params[:filter] == nil
          cond_fields = []
          cond_vals = []
          @kanban_filters.each do |filter|
			if filter.field_name == "lignee_id" then @linked_id = filter.value_id end
            if filter.value_id < 0 then name = 'text_' else  name = 'list_' end
            if filter.field_value.to_s != "" then name = name + "custo_" + filter.field_value.to_s else name = name + "stand_" + filter.field_name.to_s end
            if cond_fields.index(name) == nil 
              cond_fields << (name) 
              val=[]
              if filter.value_id > 0
                val << filter.value_id
              else
                val << filter.value_name
              end
              cond_vals << val
            else
              i = cond_fields.index(name)
              if filter.value_id > 0
                cond_vals[i] << filter.value_id
              else
                cond_vals[i] << filter.value_name
              end
            end
          end
          string_select = buid_string_select(cond_fields, cond_vals)
        end

        if params[:filter] != nil and @kanban_tempo_filters != nil
          cond_fields = []
          cond_vals = []
          @kanban_tempo_filters.each do |filter|
			if filter[0] == "lignee_id" then @linked_id = filter[2] end
            if filter[2] < 0 then name = 'text_' else  name = 'list_' end
            if filter[1].to_s != "" then name = name + "custo_" + filter[1].to_s else name = name + "stand_" + filter[0].to_s end
            if cond_fields.index(name) == nil 
              cond_fields << (name) 
              val=[]
              if filter[2] > 0
                val << filter[2]
              else
                val << filter[3]
              end
              cond_vals << val
            else
              i = cond_fields.index(name)
              if filter[2] > 0
                cond_vals[i] << filter[2]
              else
                cond_vals[i] << filter[3]
              end
            end
          end
          string_select = buid_string_select(cond_fields, cond_vals)
        end
      
     
        if string_select.to_s == ""
          @fiches = Kanban.select("distinct fiches.*, cycles.name as cycle_name, type_fiches.color, type_fiches.is_gherkin, father.name as fathername, lignee.name as ligneename,
			case when type_fiches.is_gherkin and fiches.test_id is null then 'red' when type_fiches.is_gherkin and fiches.test_id is not null then 'green' else '' end as hastest,
			case when type_fiches.is_gherkin and fiches.test_id is not null then case when fiches.lastresult = 'PASS' then 'green' else 'red' end else 'red' end  as hasrun")
          .joins("INNER JOIN kanban_type_fiches on kanban_type_fiches.domaine_id = kanbans.domaine_id and kanban_type_fiches.kanban_id = kanbans.id")
          .joins("INNER JOIN kanban_statuses on kanban_statuses.domaine_id = kanbans.domaine_id and kanban_statuses.kanban_id = kanbans.id")
          .joins("INNER JOIN fiches on fiches.domaine_id = kanbans.domaine_id and fiches.type_fiche_id = kanban_type_fiches.type_fiche_id and kanban_statuses.status_id = fiches.status_id")
          .joins("LEFT OUTER JOIN fiches as father on father.id = fiches.father_id")
          .joins("LEFT OUTER JOIN fiches as lignee on lignee.id = fiches.lignee_id")
          .joins("INNER JOIN type_fiches on type_fiches.domaine_id = fiches.domaine_id and type_fiches.id = fiches.type_fiche_id")
          .joins("LEFT OUTER JOIN cycles on cycles.domaine_id = fiches.domaine_id and cycles.id = fiches.cycle_id")
          .where("kanbans.id = #{kanban_id} and fiches.project_id = #{@selectedproject}").limit(1000)
          .order("fiches.#{@groupby}").all
        else
          if string_select.include? "create_users.id"
            @fiches = Kanban.select("distinct fiches.*, cycles.name as cycle_name, type_fiches.color, type_fiches.is_gherkin, father.name as fathername, lignee.name as ligneename,
			case when type_fiches.is_gherkin and fiches.test_id is null then 'red' when type_fiches.is_gherkin and fiches.test_id is not null then 'green' else '' end as hastest,
			case when type_fiches.is_gherkin and fiches.test_id is not null then case when fiches.lastresult = 'PASS' then 'green' else 'red' end else 'red' end  as hasrun")
            .joins("INNER JOIN kanban_type_fiches on kanban_type_fiches.domaine_id = kanbans.domaine_id and kanban_type_fiches.kanban_id = kanbans.id")
            .joins("INNER JOIN kanban_statuses on kanban_statuses.domaine_id = kanbans.domaine_id and kanban_statuses.kanban_id = kanbans.id")
            .joins("INNER JOIN fiches on fiches.domaine_id = kanbans.domaine_id and fiches.type_fiche_id = kanban_type_fiches.type_fiche_id and kanban_statuses.status_id = fiches.status_id")
            .joins("LEFT OUTER JOIN fiches as father on father.id = fiches.father_id")
            .joins("LEFT OUTER JOIN fiches as lignee on lignee.id = fiches.lignee_id")
            .joins("INNER JOIN users as create_users on fiches.domaine_id = create_users.domaine_id and create_users.username = fiches.user_cre")
            .joins("INNER JOIN type_fiches on type_fiches.domaine_id = fiches.domaine_id and type_fiches.id = fiches.type_fiche_id")
            .joins("LEFT OUTER JOIN cycles on cycles.domaine_id = fiches.domaine_id and cycles.id = fiches.cycle_id")
            .where("kanbans.id = #{kanban_id} and fiches.project_id = #{@selectedproject} and #{string_select}").limit(1000)
            .order("fiches.#{@groupby}").all
          else
            @fiches = Kanban.select("distinct fiches.*, cycles.name as cycle_name, type_fiches.color, type_fiches.is_gherkin, father.name as fathername, lignee.name as ligneename,
			case when type_fiches.is_gherkin and fiches.test_id is null then 'red' when type_fiches.is_gherkin and fiches.test_id is not null then 'green' else '' end as hastest,
			case when type_fiches.is_gherkin and fiches.test_id is not null then case when fiches.lastresult = 'PASS' then 'green' else 'red' end else 'red' end  as hasrun")
            .joins("INNER JOIN kanban_type_fiches on kanban_type_fiches.domaine_id = kanbans.domaine_id and kanban_type_fiches.kanban_id = kanbans.id")
            .joins("INNER JOIN kanban_statuses on kanban_statuses.domaine_id = kanbans.domaine_id and kanban_statuses.kanban_id = kanbans.id")
            .joins("INNER JOIN fiches on fiches.domaine_id = kanbans.domaine_id and fiches.type_fiche_id = kanban_type_fiches.type_fiche_id and kanban_statuses.status_id = fiches.status_id")
            .joins("LEFT OUTER JOIN fiches as father on father.id = fiches.father_id")
            .joins("LEFT OUTER JOIN fiches as lignee on lignee.id = fiches.lignee_id")
            .joins("INNER JOIN type_fiches on type_fiches.domaine_id = fiches.domaine_id and type_fiches.id = fiches.type_fiche_id")
            .joins("LEFT OUTER JOIN cycles on cycles.domaine_id = fiches.domaine_id and cycles.id = fiches.cycle_id")
            .where("kanbans.id = #{kanban_id} and fiches.project_id = #{@selectedproject} and #{string_select}").limit(1000)
            .order("fiches.#{@groupby}").all
          end
        end
      end
	  end
    end
    @name = params[:sname].to_s
    if @name != ""
      @kanbans = Kanban.where("domaine_id = #{@domaine} and name like '%#{@name}%' and is_active = 1 and (private = 0 or owner_user_id = #{@my_user_id})").order(:name).all
    else  
      @kanbans = Kanban.where("domaine_id = #{@domaine} and is_active = 1 and (private = 0 or owner_user_id = #{@my_user_id})").order(:name).all
    end 
  end

  def getone
    flash[:kanban_id] = params[:kanban_id].to_s
    redirect_to controller: 'kanbans', action: 'index'
  end
  
  def parametrize
    @name = params[:sname].to_s
    kanban_id = (params[:kanban_id] != nil ? params[:kanban_id] : (flash[:kanban_id] != nil ? flash[:kanban_id] : cookies[:kanban_id])).to_s
    b = (params[:b] != nil ? params[:b] : flash[:b]).to_s
    @message = nil
 	
    if @name != ""
      @kanbans = Kanban.select("kanbans.*").where("domaine_id = #{@domaine} and name like '%#{@name}%' and (private = 0 or owner_user_id = #{@my_user_id})").order("case when father_id is null then id else father_id end, id").all
    else  
      @kanbans = Kanban.select("kanbans.*").where("domaine_id = #{@domaine} and (private = 0 or owner_user_id = #{@my_user_id})").order("case when father_id is null then id else father_id end, id").all
    end 
   
    if kanban_id != ""
	  @message, @OK = Commun.set_message(flash[:ko])
      @kanban = Kanban.where(:id => kanban_id).first
      if @kanban != nil 
        if b == "addfilter"
          kanban = Kanban.new
          kanban.name =  @kanban.name + "_" + t('filtre')
          kanban.domaine_id = @domaine
          kanban.is_active = 1
          kanban.father_id = @kanban.id
          if  @can_manage_worflows_and_card != 1 then kanban.private = 1 else kanban.private = 0 end
          kanban.owner_user_id = @my_user_id
          kanban.save
          @kanban = kanban
        end
 
        if b == "edit" and @kanban.father_id == nil
          @kanban_statuses = Liste
          .select("liste_values.id as status_id, liste_values.value as status_name, kanban_statuses.kanban_id as kanban_id, kanban_statuses.status_order as status_order")
          .joins("INNER JOIN liste_values on listes.domaine_id = liste_values.domaine_id and listes.id = liste_values.liste_id")
          .joins("LEFT OUTER JOIN kanban_statuses on liste_values.domaine_id = kanban_statuses.domaine_id and liste_values.id = kanban_statuses.status_id and kanban_statuses.kanban_id = #{kanban_id}")
          .where("listes.domaine_id = #{@domaine} and listes.code ='WKF_STATUS'")
          .all.order("kanban_statuses.status_order, liste_values.id")
          @kanban_type_fiches = TypeFiche
          .select("type_fiches.id as type_fiche_id, kanban_type_fiches.kanban_id as kanban_id, type_fiches.name as name")
          .joins("LEFT OUTER JOIN kanban_type_fiches on type_fiches.domaine_id = kanban_type_fiches.domaine_id and type_fiches.id = kanban_type_fiches.type_fiche_id and kanban_type_fiches.kanban_id = #{kanban_id}")
          .where("type_fiches.domaine_id = #{@domaine}").all
        end
      
        if @kanban.father_id != nil
          @kanban_filters = KanbanFilter.where(:domaine_id => @domaine, :kanban_id => @kanban.id).all
          @type_fiches, @kanban_statuses, @all_priorities, @all_cycles, @all_users, @bloc_custo, @bloc_custo_updt = get_filters_lists_and_build_html_custo_fields(@kanban.father_id)
        end
      end
    end    
  end  
    

   
  def update
    kanban_id = params[:kanban_id].to_s
    if @can_manage_worflows_and_card == 1
      
      if params[:delete] != nil
        kanban = Kanban.where(:id => kanban_id).first
        if kanban != nil 
          kanbansons = Kanban.where(:domaine_id => @domaine, :father_id => kanban_id).all
          kanbansons.each do |son|
            son.destroy
          end
          kanban.destroy
        end
      end

      if params[:valid] != nil
        kanban = Kanban.where(:id => kanban_id).first
        flash[:ko] = 1
        if kanban != nil
          if params[:actif].to_s == "on" then kanban.is_active = 1 else kanban.is_active = 0 end
          if params[:private].to_s == "on" then kanban.private = 1 else kanban.private = 0 end
          if params[:name].to_s.strip != "" then kanban.name = params[:name].to_s.strip end
          kanban.description = params[:desc]
          kanban.save
          
          if kanban.father_id == nil
            # KANBAN PERE
            KanbanTypeFiche.where(:domaine_id => @domaine, :kanban_id => kanban_id).delete_all
            KanbanStatus.where(:domaine_id => @domaine, :kanban_id => kanban_id).delete_all
            order_status = 0
            params.each do |lparam|
			  if params["#{lparam}"]==nil then param = "#{lparam[0]}" else param = "#{lparam}" end
              if param.to_s.start_with? "chbxtf"
                nomparam = param.to_s
                if params[nomparam].to_s == "on"
                  type_fiche_id = nomparam.to_s.split("-")
                  KanbanTypeFiche.new(:domaine_id => @domaine, :kanban_id => kanban_id, :type_fiche_id => type_fiche_id[1]).save
                end
              end
              if param.to_s.start_with? "chbxst"
                nomparam = param.to_s
                if params[nomparam].to_s == "on"
                  order_status += 1
                  type_fiche_id = nomparam.to_s.split("$-$")
                  KanbanStatus.new(:domaine_id => @domaine, :kanban_id => kanban_id, :status_id => type_fiche_id[1], :status_name => type_fiche_id[2], :status_order => order_status).save
                end
              end
            end
          else
            #KANBAN FILS = FILTRE
            save_filters(kanban_id, params)
          end
          flash[:kanban_id] = kanban.id
          flash[:b] = 'edit'
        end   
      end
    end    
    redirect_to controller: 'kanbans', action: 'parametrize'
  end
  

  
  def new
    if @can_manage_worflows_and_card == 1
      kanban = Kanban.new
      kanban.name =  params[:namec]
      kanban.domaine_id = @domaine
      kanban.is_active = 1
      kanban.private = 0
      kanban.owner_user_id = @my_user_id
      kanban.save
      flash[:kanban_id] = kanban.id
      flash[:b] = 'edit'
    end
    redirect_to controller: 'kanbans', action: 'parametrize'
  end  
  
  
  private
  
  def save_filters(kanban_id, params)
    KanbanFilter.where(:domaine_id => @domaine, :kanban_id => kanban_id).delete_all
    params.each do |lparam|
	  if params["#{lparam}"]==nil then param = "#{lparam[0]}" else param = "#{lparam}" end
      if param.to_s.start_with? "status_id"
        kanban_filter = KanbanFilter.new(domaine_id: @domaine, kanban_id: kanban_id, field_name: 'status_id', value_id: params[param], value_name: 'empty_please_use_id')
        kanban_filter.save
      end
      if param.to_s.start_with? "type_fiche_id"
        kanban_filter = KanbanFilter.new(domaine_id: @domaine, kanban_id: kanban_id, field_name: 'type_fiche_id', value_id: params[param], value_name: 'empty_please_use_id')
        kanban_filter.save
      end
      if param.to_s.start_with? "cycle_id"
        kanban_filter = KanbanFilter.new(domaine_id: @domaine, kanban_id: kanban_id, field_name: 'cycle_id', value_id: params[param], value_name: 'empty_please_use_id')
        kanban_filter.save
      end
      if param.to_s.start_with? "priority_id"
        kanban_filter = KanbanFilter.new(domaine_id: @domaine, kanban_id: kanban_id, field_name: 'priority_id', value_id: params[param], value_name: 'empty_please_use_id')
        kanban_filter.save
      end
      if param.to_s.start_with? "user_assign_id"
        kanban_filter = KanbanFilter.new(domaine_id: @domaine, kanban_id: kanban_id, field_name: 'user_assign_id', value_id: params[param], value_name: 'empty_please_use_id')
        kanban_filter.save
      end
      if param.to_s.start_with? "user_cre_id"
        kanban_filter = KanbanFilter.new(domaine_id: @domaine, kanban_id: kanban_id, field_name: 'user_cre_id', value_id: params[param], value_name: 'empty_please_use_id')
        kanban_filter.save
      end
      if param.to_s.start_with? "custoliste$$"
        kanban_filter = KanbanFilter.new(domaine_id: @domaine, kanban_id: kanban_id, field_name: 'ucf_name', field_value: param.to_s.split('$$')[1], value_id: params[param], value_name: 'empty_please_use_id')
        kanban_filter.save
      end
      if param.to_s.start_with? "custotext$$"
        if params[param].to_s.strip != ""
          kanban_filter = KanbanFilter.new(domaine_id: @domaine, kanban_id: kanban_id, field_name: 'ucf_name', field_value: param.to_s.split('$$')[1], value_id: -1, value_name: params[param])
          kanban_filter.save
        end
      end
	  if param.to_s.start_with? "linked_id"
		if params[param].to_s.strip != ""
			kanban_filter = KanbanFilter.new(domaine_id: @domaine, kanban_id: kanban_id, field_name: 'lignee_id', value_id: params[param], value_name: 'empty_please_use_id')
			kanban_filter.save
		end
      end
    end
  end



  def get_filters_lists_and_build_html_custo_fields(kanban_id)
    type_fiches = KanbanTypeFiche.select("type_fiches.*").joins("INNER JOIN type_fiches on type_fiches.domaine_id = kanban_type_fiches.domaine_id and type_fiches.id = kanban_type_fiches.type_fiche_id").where("kanban_type_fiches.domaine_id = #{@domaine} and kanban_type_fiches.kanban_id = #{kanban_id}").all.order("type_fiches.name")
    kanban_statuses = KanbanStatus.where(:domaine_id => @domaine, :kanban_id => kanban_id).all.order(:status_order)
    
    all_priorities = Liste.select("liste_values.*").joins("INNER JOIN liste_values on listes.domaine_id = liste_values.domaine_id and listes.id = liste_values.liste_id").where("listes.domaine_id = #{@domaine} and listes.code ='PRIORITY'").all.order("liste_values.value")

    all_cycles = Cycle.select("cycles.id, cycles.name as value")
    .joins("INNER JOIN releases on cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id")
    .where("cycles.domaine_id = #{@domaine} and releases.project_id = #{@selectedproject}").all.order("cycles.name") 
 
    all_users = User.select("distinct users.id, users.username as value")
    .joins("INNER JOIN userprojects as otherusersprojects  on otherusersprojects.domaine_id = users.domaine_id and otherusersprojects.user_id = users.id")
    .where("users.domaine_id = #{@domaine} and otherusersprojects.project_id = #{@selectedproject}").all.order("users.username") 
      
    custo_type_fiches =  TypeFiche
    .joins("INNER JOIN kanban_type_fiches on kanban_type_fiches.domaine_id = type_fiches.domaine_id and type_fiches.id = kanban_type_fiches.type_fiche_id")
    .where("kanban_type_fiches.domaine_id = #{@domaine} and kanban_type_fiches.kanban_id = #{kanban_id} and type_fiches.jsondesc is not null and type_fiches.jsondesc != '[]'")
    .all
    if custo_type_fiches != nil
      agregat_json = []
      custo_type_fiches.each do |type_fiche|
        json = JSON.parse(type_fiche.jsondesc, :quirks_mode => true)
        for i in 0..json.length-1
          if json[i]["type"] == 'list'
            newarray = [json[i]["name"] , json[i]["type"] , "code_liste:#{json[i]["code_liste"]}"]
          else
            newarray = [json[i]["name"] , json[i]["type"] , nil]
          end
          if not agregat_json.include? newarray
            agregat_json << newarray
          end
        end 
      end
      if agregat_json.to_s != nil
        agregat_json.to_s.include? 'code_liste:project'
        all_projects = Project.select("projects.id, projects.name as value")
        .joins("INNER JOIN userprojects  on userprojects.domaine_id = projects.domaine_id and userprojects.project_id = projects.id and userprojects.user_id = #{@my_user_id}")
        .where("projects.domaine_id = #{@domaine}").all.order("projects.name") 
      end 

      if agregat_json.to_s.include? 'code_liste:release'
        all_releases = Release.select("releases.id, releases.name as value")
        .where("releases.domaine_id = #{@domaine} and releases.project_id = #{@selectedproject}").all.order("releases.name") 
      end 
            
           
      if agregat_json.to_s.include? 'code_liste:campain'
        all_campains = Campain.select("campains.id, campains.name as value")
        .joins("INNER JOIN cycles on cycles.domaine_id = campains.domaine_id and cycles.id = campains.cycle_id")
        .joins("INNER JOIN releases on cycles.domaine_id = releases.domaine_id and cycles.release_id = releases.id")
        .where("cycles.domaine_id = #{@domaine} and releases.project_id = #{@selectedproject}").all.order("campains.name") 
      end 

      if agregat_json.to_s.include? 'code_liste:funcandscreen'
        all_funcandscreens = Funcandscreen.select("distinct funcandscreens.id, sheets.name as value2, funcandscreens.name as value")
        .joins("INNER JOIN nodes on nodes.domaine_id = funcandscreens.domaine_id and nodes.obj_id = funcandscreens.id and nodes.obj_type='funcscreen'")
        .joins("INNER JOIN sheets on sheets.domaine_id = nodes.domaine_id and sheets.id = nodes.sheet_id and sheets.private = 0")
        .where("sheets.version_id = #{@currentversion} and funcandscreens.domaine_id =  #{@domaine} and funcandscreens.project_id = #{@selectedproject}")
        .order("sheets.name, funcandscreens.name").all	  
      end 

      if agregat_json.to_s.include? 'code_liste:schemaapp'
        all_schemaapps = Sheet.select("sheets.id, sheets.name as value")
        .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
        .where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@currentversion} and sheets.type_sheet='conception_sheet' and sheets.private=0 and sheet_folders.project_id = #{@selectedproject}")
        .order("sheets.name").all
      end 

      if agregat_json.to_s.include? 'code_liste:testsuite'
        all_testsuites = Sheet.select("sheets.id, sheets.name as value")
        .joins("INNER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
        .where("sheets.domaine_id = #{@domaine} and sheets.version_id = #{@currentversion} and sheets.type_sheet='test_suite' and sheets.private=0 and sheet_folders.project_id = #{@selectedproject}")
        .order("sheets.name").all
      end 

      if agregat_json.to_s.include? 'code_liste:test'
        all_tests = Test.select("tests.id, tests.name as value")
        .joins("INNER JOIN test_folders on test_folders.id = tests.test_folder_id")
        .where("tests.domaine_id = #{@domaine} and tests.version_id = #{@currentversion} and tests.private=0 and test_folders.project_id = #{@selectedproject}")
        .order("tests.name").all
      end 
      bloc_custo = ""
      bloc_custo_updt = ""
      for i in 0..agregat_json.length-1
        custodiv = "<tr><td><span class='textStyle'>#{agregat_json[i][0]}</span></td><td>"
        custodivupdt = "<tr><td><span class='textStyle'>#{agregat_json[i][0]}</span></td><td>"
        if agregat_json[i][1] == 'text' or agregat_json[i][1] == 'textarea' 
          custodiv += "<input type='text' class='inputbox' id='custotext$$#{agregat_json[i][0]}' name='custotext$$#{agregat_json[i][0]}' value=''/>"
          custodivupdt += "<input type='text' class='inputbox' id='custotext$$#{agregat_json[i][0]}' name='majcustotext$$#{agregat_json[i][0]}' value=''/>"
        end
        if agregat_json[i][1] == 'list' 
          custodiv += "<div class='multiliste' name='multiliste'>"	
          custodivupdt += "<select class='inputbox' name='majcustoliste$$#{agregat_json[i][0]}'><option selected value=''>-</option>"
          code_liste = agregat_json[i][2].gsub("code_liste:", "")
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
              custodiv += "<div style='display:block;'><input style='display:inline;' type='checkbox' id='custoliste$$#{agregat_json[i][0]}$$#{listevalue.id}' name='custoliste$$#{agregat_json[i][0]}$$#{listevalue.id}' value='#{listevalue.id}' label=\"#{listevalue.value}\" onclick=\"displayfilter(this, '$custoliste$#{agregat_json[i][0]}');\">#{listevalue.value}</input></div>"
              custodivupdt += "<option value='#{listevalue.id}'>#{listevalue.value}</option>"
            end
          end
          custodiv += "</div>"	
          custodivupdt += "</select>"
        end
        bloc_custo += custodiv
        bloc_custo +="</td><td><div id=\"$custoliste$#{agregat_json[i][0]}\"></div>" 
        bloc_custo +="</td></tr>"
        bloc_custo_updt += custodivupdt
      end 
      bloc_custo = bloc_custo.html_safe
      bloc_custo_updt = bloc_custo_updt.html_safe
      return type_fiches, kanban_statuses, all_priorities, all_cycles, all_users, bloc_custo, bloc_custo_updt
         
    end
  end
  
  def settemporaryfilter(parameters)
    filters = []
    parameters.each do |param|
      if param.to_s.start_with? "fiche_desc"
        filters << ['name', "", -1, parameters[param]]
      end
      if param.to_s.start_with? "type_fiche_id"
        filters << ['type_fiche_id', "", parameters[param].to_i, 'empty_please_use_id']
      end
      if param.to_s.start_with? "status_id"
        filters << ['status_id', "", parameters[param].to_i, 'empty_please_use_id']
      end
      if param.to_s.start_with? "cycle_id"
        filters << ['cycle_id', "", parameters[param].to_i, 'empty_please_use_id']
      end
      if param.to_s.start_with? "priority_id"
        filters << ['priority_id', "", parameters[param].to_i, 'empty_please_use_id']
      end
      if param.to_s.start_with? "user_assign_id"
        filters << ['user_assign_id', "", parameters[param].to_i, 'empty_please_use_id']
      end
      if param.to_s.start_with? "user_cre_id"
        filters << ['user_cre_id', "", parameters[param].to_i, 'empty_please_use_id']
      end
      if param.to_s.start_with? "custoliste$$"
        filters << ['ucf_name', param.to_s.split('$$')[1], parameters[param].to_i,'empty_please_use_id']
      end
      if param.to_s.start_with? "custotext$$"
        if parameters[param].to_s.strip != ""
          filters << ['ucf_name', param.to_s.split('$$')[1], -1, parameters[param]]
        end
      end
	  if param.to_s == "linked_id"
        if parameters[param].to_s.strip != ""
		  fiche = Fiche.where(:id => parameters[param]).first
		  if fiche != nil and fiche.lignee_id != nil
			filters << ['lignee_id', "", parameters[param].to_i, 'empty_please_use_id']
		  end
        end
      end
    end
	puts filters.to_s
    return filters
  end
  
  
  def massive_update(params)
    fiches_id = params[:massids].to_s.split(";")
    fiches_id.each do |fiche_id|
      if fiche_id.to_s != ""
        fiche = Fiche.where(:id => fiche_id).first
        if fiche != nil
          if params[:majstatus] != ""
            fiche.status_id = params[:majstatus].to_s.split('|$|')[0]
            fiche.status = params[:majstatus].to_s.split('|$|')[1]
          end
          if params[:majcycle] != ""
            fiche.cycle_id = params[:majcycle]
          end
          if params[:majpriority] != ""
            fiche.priority_id = params[:majpriority].to_s.split('|$|')[0]
            fiche.priority_name = params[:majpriority].to_s.split('|$|')[1]
          end
          if params[:majassigne_a] != ""
            fiche.user_assign_id = params[:majassigne_a].to_s.split('|$|')[0]
            fiche.user_assign_name = params[:majassigne_a].to_s.split('|$|')[1]
          end
          fiche.save
          params.each do |lparam|
			if params["#{lparam}"]==nil then param = "#{lparam[0]}" else param = "#{lparam}" end
            if params[param].to_s != ""
              if param.start_with? "majcustoliste"
                FicheCustoField.where("domaine_id = #{@domaine} and fiche_id = #{fiche_id} and ucf_name = '#{param.to_s.split('$$')[1]}'").update_all("field_id = #{params[param]}")
              end
              if param.start_with? "majcustotext"
                FicheCustoField.where("domaine_id = #{@domaine} and fiche_id = #{fiche_id} and ucf_name = '#{param.to_s.split('$$')[1]}'").update_all("field_value = '#{params[param]}'")
              end
            end
          end
        end
      end
    end
  end
  
  
  def buid_string_select(cond_fields, cond_vals)
          string_select = ""
          for i in 0..cond_fields.length-1
          
            if cond_fields[i].start_with? "list_stand_"
              if string_select != "" then string_select += ' and ' end
              string_select += "fiches." + cond_fields[i].gsub("list_stand_","")
              string_select = string_select.gsub("fiches.user_cre_id", "create_users.id")
              if cond_vals[i].length == 1
                string_select += " = " + cond_vals[i][0].to_s
              else
                string_select += " in ("
                for j in 0..cond_vals[i].length-1
                  string_select += cond_vals[i][j].to_s + " , "
                end
                string_select = string_select[0..string_select.length-3] + ")"
              end
            end
            if cond_fields[i].start_with? "text_stand_"
              if cond_vals[i][0].to_s != ""
                if string_select != "" then string_select += ' and ' end
                string_select += "fiches." + cond_fields[i].gsub("text_stand_","")
                string_select = string_select.gsub("fiches.user_cre_id", "create_users.id")
                string_select += " like '%" + cond_vals[i][0].to_s + "%'"
              end
            end
            if cond_fields[i].start_with? "text_custo_"
              if cond_vals[i][0].to_s != ""
                if string_select != "" then string_select += ' and ' end
                string_select += "1 = (select 1 from fiche_custo_fields where fiche_id = fiches.id and ucf_name = '" + cond_fields[i].gsub("text_custo_","") + "' and field_value "
                string_select += " like '%" + cond_vals[i][0].to_s + "%' limit 1)"
              end
            end
            if cond_fields[i].start_with? "list_custo_"
              if string_select != "" then string_select += ' and ' end
              string_select += "1 = (select 1 from fiche_custo_fields where fiche_id = fiches.id and ucf_name = '" + cond_fields[i].gsub("list_custo_","") + "' and field_id "
            
              if cond_vals[i].length == 1
                string_select += " = " + cond_vals[i][0].to_s + " limit 1)"
              else
                string_select += " in ("
                for j in 0..cond_vals[i].length-1
                  string_select += cond_vals[i][j].to_s + " , "
                end
                string_select = string_select[0..string_select.length-3] + ") limit 1)"
              end
            end
          end
		  return string_select
		end
end 

