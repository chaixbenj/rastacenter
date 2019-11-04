class UsersController < ApplicationController
  skip_before_action :require_login, only: [:login]

  def login
    @donotshowmenu = true
    p_login = params[:login].to_s
    if params["dec"].to_s == "1" then @message = "#{t('message.vous_avez_ete_deconnecte')}" else @message = nil end
    if p_login != ""
      user_locked = User.where(:login => p_login, :locked => 1).first
      if user_locked == nil
        p_pwd = params[:pwd].to_s
        _encryptedpassword = Commun.get_encrypted_password(p_pwd)
        is_user_ok = User.where(:login => p_login, :pwd => _encryptedpassword[0..49]).first
        if is_user_ok != nil
		  if p_login == "viewer"
			is_user_ok.username = "viewer" + (is_user_ok.username.gsub("viewer","").to_s.to_i + 1).to_s
			is_user_ok.save
		  end
          domaine = Domaine.where(:id => is_user_ok.domaine_id).first
          @domaine_guid = domaine.guid

		  @idnavigation = is_user_ok.is_admin.to_s + (SecureRandom.uuid).to_s
		  is_user_ok.idnavigation=@idnavigation
		  is_user_ok.dateidnavigation=Time.now.utc
		  is_user_ok.locked = 0
		  is_user_ok.save
		  session[:uid] = is_user_ok.id
		  session[:domaine_id] = @domaine_guid
		  session[:username] = is_user_ok.username
		  session[:mylogin] = is_user_ok.login
		  cookies[:datenavigation] = Time.now.utc.to_i.to_s
		  cookies[:nid] = @idnavigation
		  cookies[:profilloaded] = '0'
		  Lockobject.where(:domaine => is_user_ok.domaine_id, :user_id => is_user_ok.id).delete_all
		  cookies[:objectlocked] = '0'
		  if p_login == 'superadmin'
			redirect_to controller: 'domaines', action: 'index'
		  else
			cookies[:languealfyft] = params[:locale]
			if cookies[:lastpage] != nil and is_user_ok.project_id != nil
			  begin
				redirect_to controller: cookies[:lastpage].gsub("step", ""), action: 'index', sheettype: cookies[:sheettype]
			  rescue
				redirect_to controller: 'projects', action: 'welcome'
			  end
			else
			  redirect_to controller: 'projects', action: 'welcome'
			end
		  end


        else
          user = User.where(:login => p_login).first
          if user != nil
            if user.locked != nil and user.locked > 1 then user.locked = user.locked - 1 else user.locked = 5 end
            user.save
          end
          @message =  I18n.t "message.id_pwd_incorrect"
        end
      else
        @message =  I18n.t "message.compte_verrouille"
      end
    end
  end

  def logout
    cookies.delete(:datenavigation)
    cookies.delete(:nid)
    session[:uid] = nil
    session[:username] = nil
    user = User.where(:id => @my_user_id).first
    user.idnavigation = nil
    user.dateidnavigation = nil
    user.save
    Lockobject.where(:domaine => user.domaine_id, :user_id => user.id).delete_all
    cookies[:objectlocked] = '0'
    redirect_to controller: 'users', action: 'login', dguid: params[:domaine]
  end


  def index
    user_id = (params[:usid] != nil ? params[:usid] : flash[:usid]).to_s
    @uname = params[:unames].to_s
    @user = nil
    users = User.select("users.*").where("domaine_id = #{@domaine}").order(:username).all
    if @uname != ""
      @users = User.select("users.*").where("(domaine_id = #{@domaine}) and (username like '%#{@uname}%' or login like '%#{@uname}%')") .order(:username).all
    else
      @users = users
    end
    @roles = Role.where(:domaine_id => @domaine).all

	@message, @OK = Commun.set_message(flash[:ko])
    if user_id != ""
      @user = User.where(:id => user_id).first
      @projects = Project.select("projects.*, roles.name as rolename").joins("INNER JOIN userprojects allproj on allproj.project_id = projects.id LEFT OUTER JOIN userprojects userproj on allproj.project_id = userproj.project_id and userproj.user_id = #{flash[:usid]} LEFT OUTER JOIN roles on roles.id = userproj.role_id").where("allproj.user_id = #{@my_user_id}" ).order("projects.name").all
    end
  end

  def getone
    flash[:usid] = params[:usid].to_s
    redirect_to controller: 'users', action: 'index'
  end

  def update
    usid = params[:usid].to_s
    email = params["email"].to_s
    locked = params["locked"]
    if (@can_manage_user == 1 or usid = @p_userid)
      if params[:delete] != nil
        user = User.where(:id => usid).first
        if user != nil and user.id != @p_userid
          Fiche.where(:user_assign_id => user.id).update_all(:user_assign_id => nil)
          user.destroy
        end
      end

      if params[:valid] != nil
        @projects = Project.select("projects.*").joins("INNER JOIN userprojects on project_id = projects.id").where("userprojects.user_id = #{@my_user_id}").order("projects.name").all
        user = User.where(:id => usid).first
        flash[:ko] =  "1"
        if user != nil
          user.username = params[:uname].to_s
          if User.where("login = '#{params[:ulogin].to_s}' and id != #{usid}").first == nil
            user.login = params[:ulogin].to_s
          else
            flash[:ko] =  "15"
          end
          if params[:upwd].to_s != params[:upwdc].to_s
            flash[:ko] = "14"
          else
            if params[:upwd].to_s != 'no change!'
              _encryptedpassword = Commun.get_encrypted_password(params[:upwd].to_s)
              user.pwd = _encryptedpassword[0..49]
            end
          end
          if user.id != @my_user_id and flash[:ko] ==  "1"
            @projects.each do |project|
              if params["uproj#{project.id}"] != nil and params["uprole#{project.id}"].to_s != ""
                userproject = Userproject.where(:user_id => usid, :project_id => project.id).first
                if userproject == nil
                  userproject = Userproject.new
                end
                userproject.domaine_id = @domaine
                userproject.user_id = usid
                userproject.project_id = project.id
                userproject.role_id = params["uprole#{project.id}"]
                userproject.save
                if user.project_id == nil
                  user.project_id = project.id
                  user.save
                end
              else
                userproject = Userproject.where(:user_id => usid, :project_id => project.id).first
                if userproject != nil
                  userproject.destroy
                end
              end
            end
			user.email = email
			if locked == nil then user.locked = 0 else user.locked = 1 end
			user.save
          end
          flash[:usid] = user.id
        end
      end
    end
    redirect_to controller: 'users', action: 'index'
  end


  def new
    users = User.where("domaine_id = #{@domaine}").all
    if @can_manage_user == 1 
      if User.where(:login => params[:unamec]).first == nil
        user = User.new
        user.username =  params[:unamec]
        user.login = params[:unamec]
        user.pwd = ""
        user.domaine_id = @domaine
        user.is_admin = 0
        user.save
        user_preference = UserPreference.new
        user_preference.domaine_id = @domaine
        user_preference.user_id = user.id
        user_preference.save
        flash[:usid] = user.id
      else
        flash[:ko] = "15"
      end
	  end
	  redirect_to controller: 'users', action: 'index'
  end


	def delete_domaine
		if @is_admin == 1
			domaine = Domaine.where(:id => @domaine).first
			user = User.where(:id => @my_user_id).first
			dom_id = @domaine
			Lockobject.where(:domaine_id => dom_id).delete_all
			LinkObjVersion.where(:domaine_id => dom_id).delete_all
			RequiredGem.where(:domaine_id => dom_id).delete_all
			FicheLink.where(:domaine_id => dom_id).delete_all
			FicheHisto.where(:domaine_id => dom_id).delete_all
			FicheDownload.where(:domaine_id => dom_id).delete_all
			FicheCustoField.where(:domaine_id => dom_id).delete_all
			Test.where("domaine_id = #{@domaine} and fiche_id is not null").update_all(:fiche_id => nil)
			Fiche.where(:domaine_id => dom_id).delete_all
			KanbanTypeFiche.where(:domaine_id => dom_id).delete_all
			KanbanStatus.where(:domaine_id => dom_id).delete_all
			KanbanFilter.where(:domaine_id => dom_id).delete_all
			Kanban.where(:domaine_id => dom_id).delete_all
			TypeFiche.where(:domaine_id => dom_id).delete_all
			RunSuiteScheme.where(:domaine_id => dom_id).delete_all
			RunStoreDatum.where(:domaine_id => dom_id).delete_all
			RunScreenshot.where(:domaine_id => dom_id).delete_all
			RefScreenshot.where(:domaine_id => dom_id).delete_all
			RunStepResult.where(:domaine_id => dom_id).delete_all
			RunEndedNode.where(:domaine_id => dom_id).delete_all
			RunConfig.where(:domaine_id => dom_id).delete_all
			RunAuthentication.where(:domaine_id => dom_id).delete_all
			Run.where(:domaine_id => dom_id).update_all("run_father_id = null")
			Run.where(:domaine_id => dom_id).delete_all
			RunAuthentication.where(:domaine_id => dom_id).delete_all
			ComputerLastGet.where(:domaine_id => dom_id).delete_all
			CampainConfig.where(:domaine_id => dom_id).delete_all
			CampainTestSuiteForcedConfig.where(:domaine_id => dom_id).delete_all
			CampainTestSuite.where(:domaine_id => dom_id).delete_all
			Campain.where(:domaine_id => dom_id).delete_all
			DefaultUserConfig.where(:domaine_id => dom_id).delete_all
			TestStep.where(:domaine_id => dom_id).delete_all
			Test.where(:domaine_id => dom_id).delete_all
			TestFolder.where(:domaine_id => dom_id).update_all("test_folder_father_id = null")
			TestFolder.where(:domaine_id => dom_id).delete_all
			NodeForcedConfig.where(:domaine_id => dom_id).delete_all
			NodeForcedComputer.where(:domaine_id => dom_id).delete_all
			ConfigurationVariableValue.where(:domaine_id => dom_id).delete_all
			ConfigurationVariable.where(:domaine_id => dom_id).delete_all
			ProcedureAction.where(:domaine_id => dom_id).delete_all
			Procedure.where(:domaine_id => dom_id).delete_all
			Domelement.where(:domaine_id => dom_id).delete_all
			Action.where(:domaine_id => dom_id).delete_all
			TestConstante.where(:domaine_id => dom_id).delete_all
			Findstrategie.where(:domaine_id => dom_id).delete_all
			Funcandscreen.where(:domaine_id => dom_id).delete_all
			Link.where(:domaine_id => dom_id).delete_all
			Node.where(:domaine_id => dom_id).delete_all
			Sheet.where(:domaine_id => dom_id).delete_all
			SheetFolder.where(:domaine_id => dom_id).update_all("sheet_folder_father_id = null")
			SheetFolder.where(:domaine_id => dom_id).delete_all
			AppiumCapValue.where(:domaine_id => dom_id).update_all("init_value_id = null")
			AppiumCapValue.where(:domaine_id => dom_id).delete_all
			AppiumCap.where(:domaine_id => dom_id).delete_all
			EnvironnementVariable.where(:domaine_id => dom_id).update_all("init_variable_id = null")
			EnvironnementVariable.where(:domaine_id => dom_id).delete_all
			Environnement.where(:domaine_id => dom_id).delete_all
			DataSetVariable.where(:domaine_id => dom_id).update_all("init_variable_id = null")
			DataSetVariable.where(:domaine_id => dom_id).delete_all
			DataSet.where(:domaine_id => dom_id).delete_all
			ListeValue.where(:domaine_id => dom_id).delete_all
			Liste.where(:domaine_id => dom_id).delete_all
			Computer.where(:domaine_id => dom_id).delete_all
			Userproject.where(:domaine_id => dom_id).delete_all
			UserPreference.where(:domaine_id => dom_id).delete_all
			Role.where(:domaine_id => dom_id).delete_all
			UserNotification.where(:domaine_id => dom_id).delete_all
			User.where(:domaine_id => dom_id).delete_all
			Cycle.where(:domaine_id => dom_id).delete_all
			Release.where(:domaine_id => dom_id).delete_all
			ProjectVersion.where(:domaine_id => dom_id).delete_all
			Version.where(:domaine_id => dom_id).delete_all
			Project.where(:domaine_id => dom_id).delete_all
			domaine = Domaine.where(:id => dom_id).first
			domaine.destroy
		end
		redirect_to controller: 'pages', action: 'index', ok: true, message: t('message.supp_domaine')


	end


end
