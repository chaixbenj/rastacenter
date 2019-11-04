class ActionsController < ApplicationController
  before_action :require_login


  
  
  def index
    #charsource = "àâäçèéêëîïôùûüñ -*/\\+£$%!:;,?.§µ¨^=(){}[]|&~#'@°\""
    #chardest= "aaaceeeeiiouuun\_____                            "
    action_id = (params[:action_id] != nil ? params[:action_id] : flash[:action_id]).to_s
    @popup = (params[:popup] != nil ? params[:popup] : flash[:popup])
    @actname = params[:actnames].to_s #.tr(charsource, chardest).gsub(" ", "")
    if @actname != ""
      @actions = Action.select("actions.*").where("domaine_id = #{@domaine} and version_id = #{@selectedversion} and (name like '%#{@actname}%' or description like '%#{@actname}%')").order(:is_modifiable, :callable_in_proc, :name).all
    else 
      @actions = Action.select("actions.*").where(:domaine_id => @domaine, :version_id => @selectedversion).order(:is_modifiable, :callable_in_proc, :name).all
    end
	@configurationvariables, @environnementvariables, @data_set_variables, @testconstantes = Commun.get_variables_and_constantes_names(@domaine, @selectedversion)
	if flash[:ko].to_s == "badcode"
	    @message = flash[:syntaxerror].to_s
		@badcode = true
		@ok = false
	else
		@message, @OK = Commun.set_message(flash[:ko].to_s)
	end
    if action_id != "" then @action = Action.where(:id => action_id).first end
  end

  
  def getone
    flash[:action_id] = params[:action_id].to_s
    redirect_to controller: 'actions', action: 'index'
  end
  
  
  def duplicate
	ko = 0
    if @can_manage_action == 1 and params[:action_id] != nil
      actiontocopy = Action.where(:id => params[:action_id]).first
      if actiontocopy != nil
        i = 0
        begin
          i += 1
        end while Action.where(:domaine_id => @domaine, :name => "#{actiontocopy.name}COPY#{i.to_s}").first != nil
        action = actiontocopy.dup
        action.name =  actiontocopy.name + "copy#{i.to_s}"
        action.action_admin_id =  @my_user_id
        action.is_modifiable = 1
        action.nb_used = 0
        action.save
        action.current_id = action.id
        action.save
        ComputerLastGet.where(:domaine_id => @domaine, :object_type => "action", :version_id => action.version_id, :get => 0).update_all(:get => 1)
        flash[:action_id] = action.id
      else
        ko = 3
      end
    end
	flash[:ko] = ko
    flash[:popup] = params[:popup]
    redirect_to controller: 'actions', action: 'index'
  end  
  
  
  def update    
    if @can_manage_action == 1
      ko = 1
      action_id = params[:action_id].to_s
      if params[:delete] != nil
        delete_action(action_id)
      end

      if params[:valid] != nil
        flash[:action_id] = action_id
        action = Action.where(:id => action_id).first
        if action != nil
          actioncode = params[:actcode].to_s
          if actioncode.has_valid_syntax
		  
            name = params[:actname].to_s #.tr(charsource, chardest).gsub(" ", "")
            if Action.where("domaine_id=#{@domaine} and name = '#{name}' and id != #{action_id} and version_id = #{@selectedversion}").first == nil
              if (action.is_modifiable == 1 or @is_admin == 1 or true == true) and name != ""
                if action.name != name
					renomme_action(action, name)
                end
                action.name = name
                action.parameters = params[:actparams][0..1023]
                action.description = params[:actdesc].to_s
                action.code = params[:actcode].to_s
                action.domaine_id =  @domaine
              end
              action.callable_in_proc = (params[:scallable] == nil ? 0 : 1)
              action.save
              ComputerLastGet.where(:domaine_id => @domaine, :object_type => "action", :version_id => action.version_id, :get => 0).update_all(:get => 1)
            else
              ko = 2
            end
          else
            ko = "badcode"
            cookies[:badactioncode] = params[:actcode].to_s
            flash[:syntaxerror] = actioncode.syntax_errors
          end
        end     
      end
    end    
	flash[:ko] = ko
    flash[:popup] = params[:popup]
    redirect_to controller: 'actions', action: 'index'
  end

            
            
  def whocallaction
    action_id = params[:action_id]
    @popup = params[:popup].to_s
    @callingactions = nil
    @actions = Action.where(:domaine_id => @domaine, :version_id => @selectedversion).all
    @syntaxerror = nil
    @bad_action = nil
    if action_id !=nil
      @action = Action.where(:id => action_id).first
	  #le code d'une action est modifiée dans lécran de recherche des actions appelant une action
      if params[:action_id_mod] != nil and params[:actcode] != nil
		@bad_action, @syntaxerror, @OK = update_action_code(params[:action_id_mod], params[:actcode])
      end
      if @action != nil and params[:replacingaction].to_s != "" and params[:actionlist].to_s != ""
        #remplacement d'une action par une autre
        rempaction = Action.where(:id => params[:replacingaction]).first
        if rempaction != nil
          actions = params[:actionlist].to_s.split("||")
          actions.each do |act|
            action = Action.where(:id => act.gsub("|","").to_i).first
            if action != nil
              action.code = action.code.gsub("#{@action.name}(", "#{rempaction.name}(")
              action.save
            end
          end
          ComputerLastGet.where(:domaine_id => @domaine, :object_type => "action", :version_id => @action.version_id, :get => 0).update_all(:get => 1)
        end
      end
      @callingactions = Action.where("domaine_id = #{@domaine} and version_id = #{@selectedversion} and code like '%\\#{@action.name}(%'").all #mysql
    end
  end            
  

  def new
    if @can_manage_action == 1
      flash[:ko] = 0
      name = params[:actnamec].to_s #.tr(charsource, chardest).gsub(" ", "")
      if Action.where("domaine_id=#{@domaine} and name = '#{name}'").first == nil
        action = Action.new
        action.name =  name
        action.callable_in_proc =  1
        action.domaine_id = @domaine
        action.is_modifiable = 1
        action.version_id = @selectedversion
        action.save
        action.current_id = action.id
        action.save
        ComputerLastGet.where(:domaine_id => @domaine, :object_type => "action", :version_id => action.version_id, :get => 0).update_all(:get => 1)
        flash[:action_id] = action.id
      else
        flash[:ko] = 2
      end
    end
    flash[:popup] = params[:popup]
    redirect_to controller: 'actions', action: 'index'
  end

private
  
  
  def delete_action(action_id)
	action = Action.where(:id => action_id).first
	if action != nil and (action.nb_used == nil or action.nb_used < 1)
	  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "action", :version_id => action.version_id, :get => 0).update_all(:get => 1)
	  action.destroy
	end
  end
  
  def renomme_action(action, name)
	#renommer dans proc appellante
	procedureactions = ProcedureAction.where(:action_id => action.id).all
	procedureactions.each do |procedureaction|
		procedure = Procedure.where(:id => procedureaction.procedure_id).first
		if procedure != nil
		  procedure.code = procedure.code.gsub("action.#{action.name}(", "action.#{name}(")
		  procedure.save	
		  @procversion = procedure.version_id
		  ComputerLastGet.where(:domaine_id => @domaine, :object_type => "FuncAndScreen#{procedure.funcandscreen_id}", :version_id => @procversion, :get => 0).update_all(:get => 1)
		end
	end
	#renommer dans action appellante
	callingactions = Action.where("domaine_id = #{@domaine} and version_id = #{@selectedversion} and code like '%#{action.name}(%'").all
	callingactions.each do |callingaction|
		callingaction.code = callingaction.code.gsub("#{action.name}(", "#{name}(")
		callingaction.save
		@procaction = callingaction.version_id
		end
		if @procaction != nil
		ComputerLastGet.where(:domaine_id => @domaine, :object_type => "action", :version_id => @procaction, :get => 0).update_all(:get => 1)
		end
	end
	
	
	def update_action_code(action_id_mod,actcode)
		bad_action = syntaxerror = ok = nil
        actionmod = Action.where(:id => action_id_mod).first
        if actionmod != nil
          actioncode = actcode.to_s
          if actioncode.has_valid_syntax
            actionmod.code = actcode.to_s
            actionmod.save
            ComputerLastGet.where(:domaine_id => @domaine, :object_type => "action", :version_id => actionmod.version_id, :get => 0).update_all(:get => 1)
          else
            cookies[:badactioncode] = actcode.to_s
            bad_action = actionmod.id
            syntaxerror = actioncode.syntax_errors
            ok = false
          end
        end
		return bad_action, syntaxerror, ok
	end
end
