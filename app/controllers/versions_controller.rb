class VersionsController < ApplicationController
  before_action :require_login

  def  index
    version_id = (params[:version_id] != nil ? params[:version_id] : flash[:version_id]).to_s
    filtre = ''
    if params[:versionsearch] != nil
      filtre = " and versions.name like \"%#{params[:versionsearch]}%\""
    end
    @versions = Version.where("domaine_id = #{@domaine} #{filtre}").all
    
  
    if version_id != ""
      @version = Version.where(:id => version_id).first
      if ProjectVersion.where(:domaine_id => @domaine, :version_id => version_id).first != nil
        @has_archive = true
      else
        @has_archive = false
      end
      @projects = Project.select("projects.*, project_versions.id as project_version_id,project_versions.locked as locked")
      .joins("INNER JOIN userprojects on userprojects.domaine_id = projects.domaine_id and projects.id = userprojects.project_id")
      .joins("LEFT OUTER JOIN project_versions on project_versions.domaine_id = projects.domaine_id and project_versions.project_id = projects.id and project_versions.version_id = #{ flash[:version_id]}")
      .where("projects.domaine_id = #{@domaine} and userprojects.user_id = #{@my_user_id}").all
    end
  
	@message, @OK = Commun.set_message(flash[:ko])
  end

  def getone
	flash[:version_id] = params[:version_id].to_s
	redirect_to controller: 'versions', action: 'index'
  end
    

  def new
    if @can_manage_versions == 1
      name = Time.now.localtime.to_s[0..-7].to_s + " " + params[:versioncre].to_s
      version = Version.new
      version.domaine_id = @domaine
      version.name = name[0..49]
      version.save
      flash[:version_id] = version.id
      redirect_to controller: 'versions', action: 'index' 
    end
  end  


  def update
    version = Version.where(:id => params[:version_id]).first
    if @can_manage_versions == 1 and version != nil
      flash[:ko] = 9
      case params[:dodet].to_s
      when 'delete'
        Test.where(:domaine_id => @domaine, :version_id => version.id).update_all(:sheet_id => nil)
        TestStep.joins("INNER JOIN tests on tests.id = test_steps.atdd_test_id and tests.domaine_id = #{@domaine} and tests.version_id = #{version.id}").update_all(:sheet_id => nil, :atdd_test_id => nil)
        version.destroy
        flash[:ko] = 1
      when 'delock'
        projectversion = ProjectVersion.where(:id => params[:project_version_id]).first
        if projectversion != nil
          projectversion.locked = 0
          projectversion.save
          flash[:ko] = 1
        end
      when 'lock'
        projectversion = ProjectVersion.where(:id => params[:project_version_id]).first
        if projectversion != nil
          projectversion.locked = 1
          projectversion.save
          flash[:ko] = 1
        end
      when 'valid'
        version.name = params[:vname]
        version.save
        flash[:ko] = 1
      when 'version'
        flash[:ko] = 16
        archive_element_commun = true
        projects = Project.where(:domaine_id => @domaine).all
        projects_to_arch = []
        projects.each do |project|
          if params["vproj#{project.id}"] != nil
            projects_to_arch << project.id
            project_version = ProjectVersion.new
            project_version.domaine_id = @domaine
            project_version.version_id = version.id
            project_version.project_id = project.id
            project_version.locked = 1
            project_version.user_cre = @username
            project_version.save
          end
        end
        
        if projects_to_arch.length > 0
          LinkObjVersion.where(:domaine_id => @domaine).delete_all
          sprojects_to_arch = "(#{projects_to_arch.join(' , ')})"
            if archive_element_commun
              Versionning.version_data_set(@domaine, @currentversion, version.id)
              Versionning.version_environnement(@domaine, @currentversion, version.id)
              Versionning.version_appiumcap(@domaine, @currentversion, version.id)
              Versionning.version_gem(@domaine, @currentversion, version.id)
              Versionning.version_action(@domaine, @currentversion, version.id)
              archive_element_commun = false
            end
            Versionning.version_element(@domaine, sprojects_to_arch, @currentversion, version.id)
            Versionning.version_procedure(@domaine, sprojects_to_arch, @currentversion, version.id)
            Versionning.version_sheet(@domaine, sprojects_to_arch, @currentversion, version.id)
            Versionning.version_test(@domaine, sprojects_to_arch, @currentversion, version.id)
           
            Run
            .joins("LEFT OUTER JOIN campains on campains.id = runs.campain_id")
            .joins("LEFT OUTER JOIN cycles on cycles.id = campains.cycle_id")
            .joins("LEFT OUTER JOIN releases on releases.id = cycles.release_id")
            .joins("LEFT OUTER JOIN projects on projects.id = releases.project_id")
            .joins("LEFT OUTER JOIN tests on tests.id = runs.test_id")
            .joins("LEFT OUTER JOIN test_folders on test_folders.id = tests.test_folder_id")
            .joins("LEFT OUTER JOIN sheets on sheets.id = runs.suite_id")
            .joins("LEFT OUTER JOIN sheet_folders on sheet_folders.id = sheets.sheet_folder_id")
            .where("runs.domaine_id = #{@domaine} 
            and runs.version_id = #{@currentversion} 
            and (projects.id in #{sprojects_to_arch} or (projects.id is null and sheet_folders.project_id in #{sprojects_to_arch})  or (projects.id is null and test_folders.project_id = #{@selectedproject}))
            and runs.run_father_id is null").update_all(:version_id => version.id)
            
            
            LinkObjVersion.where(:domaine_id => @domaine).delete_all
            flash[:ko] = 17

        end
        cookies[:profilloaded] = '0'
      end
    else
      flash[:ko] = 9
    end
    flash[:version_id] = params[:version_id]
    redirect_to controller: 'versions', action: 'index'
  end    
    
end
