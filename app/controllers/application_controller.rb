class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  before_action :require_login
  before_action :set_locale
  private

  def set_locale
    @locale = params[:locale]
    if params[:locale].to_s == "" then params[:locale] = cookies[:languealfyft] end
    if params[:locale].to_s == "fr" or params[:locale].to_s == "en" or params[:locale].to_s == "es"
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
      request.env['HTTP_ACCEPT_LANGUAGE'].to_s.split(",").map do |lang| 
        l, q = lang.to_s.split(";q=")
        [l, (q || '1').to_f]
        if I18n.available_locales.to_s.index(l[0..1].to_s) != nil
          I18n.locale = l[0..1]
          break
        end
      end
    end
    @locale = I18n.locale
  end
  def default_url_options
    # { locale: I18n.locale }
    { }
  end

  def require_login
    if params[:rd] == nil and params[:nw] == nil
      @controller = params[:controller] 
      @controlleraction = params[:action]
      back_to_id = ""
      if @controlleraction == "edit"
        back_to_id = (params[:back_to_id] != nil ? params[:back_to_id] : flash[:back_to_id])
        back_to_id = (back_to_id.to_s != "" ? "?rd=1&#{back_to_id}" : "")
      end
      if @controller == "sheets" 
        sheettype = (params[:sheettype] != nil ? params[:sheettype] : (flash[:sheettype] != nil ? flash[:sheettype] : cookies[:sheettype]))
        cookies[:sheettype] = sheettype
      end
      if @controller == "tests" and (flash[:atddsteps] != nil or params[:atddsteps] != nil)
        atddsteps = (params[:atddsteps] != nil ? params[:atddsteps] : flash[:atddsteps])
        cookies[:atddsteps] = atddsteps
	  else
		atddsteps = ""
        cookies[:atddsteps] = atddsteps
      end
      case @controller 	
      when "sheets"
        @location = "<a class='divlocation' href='../#{@controller}/index?rd=1&sheettype=#{cookies[:sheettype].to_s}&#{back_to_id[1..-1]}'>" +  t("controller." + @controller + cookies[:sheettype].to_s) + "</a>"
      when "run_suite_schemes"
        @controller = "run_step_results"
        @location = "<a class='divlocation' href='../#{@controller}/index#{back_to_id}'>" + t("controller." + @controller) + "</a>"
      when "run_step_results"
        @controller = "runs"
        @location = "<a class='divlocation' href='../#{@controller}/index#{back_to_id}'>" + t("controller." + @controller) + "</a>"
      when "tests"
        if cookies[:atddsteps].to_s != ""
          @location = "<a class='divlocation' href='../#{@controller}/index?rd=1&atddsteps=1&#{back_to_id[1..-1]}'>" + t("controller.atdd") + "</a>"
        else
          @location = "<a class='divlocation' href='../#{@controller}/index#{back_to_id}'>" + t("controller." + @controller) + "</a>"
        end
      when "campains"
        if @controlleraction == "cover"
          @location = "<a class='divlocation' href='../#{@controller}/cover'>" + t("controller.couverture") + "</a>"
        else
          @location = "<a class='divlocation' href='../#{@controller}/index#{back_to_id}'>" + t("controller." + @controller) + "</a>"
        end
      when "projects"
        if @controlleraction == "welcome"
          @location = "<a class='divlocation' href='../#{@controller}/welcome?f=1'>" + t("mainmenu").to_s  + "</a>"
        else
          @location = "<a class='divlocation' href='../#{@controller}/index'>" + t("controller." + @controller) + "</a>"
        end
      else
        @location = "<a class='divlocation' href='../#{@controller}/index#{back_to_id}'>" + t("controller." + @controller) + "</a>"
      end

      @location = @location.html_safe
      cookies[:lastpagebefore] = cookies[:lastpage]
      if (params[:popup].to_s != "true" and flash[:popup] != "true") and @controller != "user_notifications"
        cookies[:lastpage] = @controller
      end
      @my_user_id = session[:uid] 
      @username = session[:username]
      @mylogin = session[:mylogin]
      @domaine_guid = session[:domaine_id]
      @p_idnavigation = cookies[:nid].to_s


	  
      if @my_user_id == nil or cookies[:datenavigation] == nil
        redirect_to users_login_url
      else
        if ((Time.now.utc.to_i - cookies[:datenavigation].to_i)/3600) > 2
          User.where(:id => @my_user_id).update_all(:idnavigation => nil, :dateidnavigation => nil)
          session[:uid] = nil
          session[:username] = nil
          session[:mylogin] = nil
          session[:domaine_id] = nil
          cookies.delete(:datenavigation)
          redirect_to users_login_url
        else  
          if @mylogin != 'superadmin'
            if @mylogin != 'viewer' and ((Time.now.utc.to_i - cookies[:datenavigation].to_i)/60) > 5
              if User.where(:id => @my_user_id, :idnavigation => @p_idnavigation).first == nil
                session[:uid] = nil
                session[:username] = nil
                session[:mylogin] = nil
                session[:domaine_id] = nil
                cookies.delete(:datenavigation)
                redirect_to controller: 'users', action: 'login', dec: 1
              end
              User.where(:id => @my_user_id).update_all(:dateidnavigation => Time.now.utc)
              cookies[:datenavigation] = Time.now.utc.to_i.to_s 
            end
            if cookies[:profilloaded] == '0' or params[:projectselectedinliste] != nil or params[:versionselectedinliste] != nil 
              user = User.where(:id => @my_user_id, :idnavigation => @p_idnavigation).first
              if user != nil 
                if params[:projectselectedinliste] != nil
                  projet = Project.where(:id => params[:projectselectedinliste]).first
                  if projet != nil
                    @selectedproject = projet.id
                    user.project_id = projet.id
                    @selectedversion = nil
                  end
                end
                user.save
                @is_admin = user.is_admin 
                @connecteduser = user.username
                @selectedproject = user.project_id
                @domaine = user.domaine_id
                if params[:versionselectedinliste] != nil
                  @selectedversion = params[:versionselectedinliste]
                  cookies.delete(:domelement_copy)
                  cookies.delete(:procedure_copy_name)
                  cookies.delete(:procedure_copy_id)
                  cookies.delete(:sheet_or_folder_to_paste)
                  cookies.delete(:test_or_folder_to_paste)
                  cookies.delete(:atdd_test_or_folder_to_paste)
                  cookies.delete(:testsuite_to_paste)
                  cookies.delete(:campain_to_paste)
                  cookies.delete(:conception_sheetsheet_or_folder_to_paste)
                  cookies.delete(:test_suitesheet_or_folder_to_paste)
                  cookies.delete(:step_to_paste0)
				  cookies.delete(:step_to_paste1)
                  cookies.delete(:testsuite_to_paste)
                  locked_project_version = ProjectVersion.where(:domaine_id => @domaine, :project_id => @selectedproject, :version_id => params[:versionselectedinliste]).first
                  if locked_project_version != nil and locked_project_version.locked == 1
                    @locked_project_version = 1
                  else
                    @locked_project_version = 0
                  end
                end
                @currentversion = Version.where(:domaine_id => user.domaine_id, :name => 'current').first.id
                if @selectedversion == nil
                  @selectedversion = @currentversion
                  @locked_project_version = 0
                end
                if @selectedproject != nil
                  myversions = Version.joins("INNER JOIN project_versions on project_versions.domaine_id = versions.domaine_id and project_versions.version_id = versions.id").where("versions.domaine_id = #{@domaine} and project_versions.project_id = #{@selectedproject}").all
                end
                if @domaine == nil and @is_admin == 1
                  @domaine = user.id
                end
                myprojects = Project.select("projects.*").joins("INNER JOIN userprojects on project_id = projects.id").where("userprojects.domaine_id = #{@domaine} and userprojects.user_id = #{@my_user_id}").order("projects.name").all
                if Project.where(:id => @selectedproject).first == nil and @mylogin != 'superadmin'
                  @selectedproject = nil
                  redirect_to controller: 'projects', action: 'welcome'
                else
                  @myrole = Userproject.where(:domaine_id => @domaine, :user_id => @my_user_id, :project_id => @selectedproject).first.role_id
                  role = Role.where(:id => @myrole).first
                  @can_manage_user = role.droits[0].to_i
                  @can_manage_role = role.droits[1].to_i
                  @can_manage_project = role.droits[2].to_i
                  @can_manage_action = role.droits[3].to_i
                  @can_manage_public_conception_sheet = role.droits[4].to_i
                  @can_manage_element = role.droits[5].to_i
                  @can_manage_procedure = role.droits[6].to_i
                  @can_manage_test_folder = role.droits[7].to_i
                  @can_manage_public_test = role.droits[8].to_i
                  @can_manage_env_variable = role.droits[9].to_i
                  @can_manage_configuration_variable = role.droits[10].to_i   
                  @can_manage_liste = role.droits[11].to_i  
                  @can_manage_public_test_suite = role.droits[12].to_i 
                  @can_manage_release = role.droits[13].to_i 
                  @can_manage_public_campain = role.droits[14].to_i 
                  @can_manage_computer = role.droits[15].to_i
                  @can_manage_test_constante = role.droits[16].to_i
                  @can_manage_appium_caps = role.droits[17].to_i
                  @can_manage_worflows_and_card = role.droits[18].to_i
                  @can_manage_versions = role.droits[19].to_i 
                  @can_manage_jdd = role.droits[20].to_i 
                  @can_manage_cards = role.droits[21].to_i 
                  @can_do_something = role.droits[22].to_i
                  if @locked_project_version == 1
                    @can_manage_action = 0
                    @can_manage_public_conception_sheet = 0
                    @can_manage_element = 0
                    @can_manage_procedure = 0
                    @can_manage_public_test = 0
                    @can_manage_env_variable = 0
                    @can_manage_public_test_suite = 0
                    @can_manage_appium_caps = 0
                  end
                end
                cookies[:profilloaded] = 
                  @is_admin.to_s + '|' + 
                  @connecteduser.to_s + '|' + 
                  @selectedproject.to_s + '|' + 
                  @selectedversion.to_s + '|' + 
                  @currentversion.to_s + '|' + 
                  @domaine.to_s + '|' + 
                  @can_manage_user.to_s + '|' + 
                  @can_manage_role.to_s + '|' + 
                  @can_manage_project.to_s + '|' + 
                  @can_manage_action.to_s + '|' + 
                  @can_manage_public_conception_sheet.to_s + '|' + 
                  @can_manage_element.to_s + '|' + 
                  @can_manage_procedure.to_s + '|' + 
                  @can_manage_test_folder.to_s + '|' + 
                  @can_manage_public_test.to_s + '|' + 
                  @can_manage_env_variable.to_s + '|' + 
                  @can_manage_configuration_variable.to_s + '|' + 
                  @can_manage_liste.to_s + '|' + 
                  @can_manage_public_test_suite.to_s  + '|' + 
                  @can_manage_release.to_s + '|' + 
                  @can_manage_public_campain.to_s + '|' + 
                  @can_manage_computer.to_s + '|' + 
                  @can_manage_test_constante.to_s + '|' + 
                  @can_manage_appium_caps.to_s + '|' + 
                  @can_manage_worflows_and_card.to_s + '|' + 
                  @can_manage_versions.to_s  + '|' +
                  @can_manage_jdd.to_s  + '|' +
                  @can_manage_cards.to_s  + '|' + 
                  @can_do_something.to_s  + '|' +
                  @locked_project_version.to_s
                smyprojects = ""
                myprojects.each do |project|
                  smyprojects += project.id.to_s + '|' + project.name + '|'
                end
                cookies[:myprojects] = smyprojects
                @myprojects = cookies[:myprojects]
                smyversions = ""
                if myversions != nil
                  myversions.each do |version|
                    smyversions += version.id.to_s + '|' + version.name + '|'
                  end
                end
                cookies[:myversions] = smyversions
                @myversions = cookies[:myversions]
              end
            else
              @myprojects = cookies[:myprojects]
              @myversions = cookies[:myversions]
              loadedprofil = cookies[:profilloaded].to_s.split('|')
              @domaine = loadedprofil[5].to_i
              @is_admin = loadedprofil[0].to_i
              @connecteduser = loadedprofil[1].to_s
              @selectedproject = loadedprofil[2].to_i
              @selectedversion = loadedprofil[3].to_i
              @currentversion = loadedprofil[4].to_i
              @can_manage_user = loadedprofil[6].to_i
              @can_manage_role = loadedprofil[7].to_i
              @can_manage_project = loadedprofil[8].to_i
              @can_manage_action = loadedprofil[9].to_i
              @can_manage_public_conception_sheet = loadedprofil[10].to_i
              @can_manage_element = loadedprofil[11].to_i
              @can_manage_procedure = loadedprofil[12].to_i
              @can_manage_test_folder = loadedprofil[13].to_i
              @can_manage_public_test = loadedprofil[14].to_i
              @can_manage_env_variable = loadedprofil[15].to_i
              @can_manage_configuration_variable = loadedprofil[16].to_i
              @can_manage_liste = loadedprofil[17].to_i
              @can_manage_public_test_suite = loadedprofil[18].to_i
              @can_manage_release = loadedprofil[19].to_i 
              @can_manage_public_campain = loadedprofil[20].to_i 
              @can_manage_computer = loadedprofil[21].to_i
              @can_manage_test_constante = loadedprofil[22].to_i
              @can_manage_appium_caps = loadedprofil[23].to_i
              @can_manage_worflows_and_card = loadedprofil[24].to_i
              @can_manage_versions = loadedprofil[25].to_i
              @can_manage_jdd = loadedprofil[26].to_i 
              @can_manage_cards = loadedprofil[27].to_i 
              @can_do_something = loadedprofil[28].to_i
              @locked_project_version = loadedprofil[29].to_i
              cookies[:profilloaded] = loadedprofil.join("|")
            end
          else
            @domaine = User.where(:id => @my_user_id).first.domaine_id
            @connecteduser = "contact_alfyft"
          end
        end
        @usernotifications = UserNotification.where(:domaine_id => @domaine, :user_id => @my_user_id, :lu => 0).all.order("id DESC")
        if params[:popup].to_s != "true" and cookies[:objectlocked] == '1' and @controller != "lockobjects"
          Lockobject.where(:domaine => @domaine, :user_id => @my_user_id).delete_all
          cookies[:objectlocked] = '0'
        end
      end
    else
      params.each do |param|
        flash["#{param.to_s}"] = params["#{param.to_s}"]
      end
      redirect_to controller: params[:controller], action: params[:action]
    end
  end  
  
end
