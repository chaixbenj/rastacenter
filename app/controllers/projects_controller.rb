class ProjectsController < ApplicationController
  before_action :require_login

  def welcome
    @message = params["message"]
    @OK = params["ok"]
    @createproject=false
    projet = Project.where(:id => @selectedproject).first
    if projet == nil
      if @myprojects == nil	or @myprojects.length == 0
        @selectedproject = nil
        if  @is_admin == 1
          @messageaccueil = I18n.t "message.creer_un_projet_pour_commencer"
          @projectname = ""
          @createproject=true
        else
          @messageaccueil = I18n.t "message.aucun_projet_contacter_administrateur"
          @projectname = ""
        end
      else
        @selectedproject = nil
        @messageaccueil = I18n.t "message.selectionnez_un_projet_pour_commencer"
        @projectname = ""
      end
    else
      @messageaccueil = I18n.t "message.bienvenue_sur_le_projet"
      @projectname = projet.name
      if cookies[:lastpagebefore] != nil and params[:f] == nil
        begin
          redirect_to controller: cookies[:lastpagebefore], action: 'index'
        rescue
        end
      end
    end
  end


  def index
    @pname = params[:pnames].to_s
    pid = (params[:pid] != nil ? params[:pid] : flash[:pid]).to_s
	  ko = (params[:ko] != nil ? params[:ko] : flash[:ko]).to_s
    if @pname != ""
      @projects = Project.select("projects.*").joins("INNER JOIN userprojects on project_id = projects.id").where("projects.domaine_id = #{@domaine} and userprojects.domaine_id = #{@domaine} and userprojects.user_id = #{@my_user_id} and projects.name like '%#{@pname}%'" ).order("projects.name").all
    else
      @projects = Project.select("projects.*").joins("INNER JOIN userprojects on project_id = projects.id").where("projects.domaine_id = #{@domaine} and userprojects.domaine_id = #{@domaine} and userprojects.user_id = #{@my_user_id}" ).order("projects.name").all
    end
    if pid != "" then
      @project = Project.where(:id => pid).first
    end
    @message, @OK = Commun.set_message(ko)
	  if @projects == nil
		    redirect_to controller: 'projects', action: 'welcome', f: 1
	  end
  end

  def getone
    flash[:pid] = params[:pid].to_s
    redirect_to controller: 'projects', action: 'index'
  end

  def new
    if @can_manage_project == 1 or @is_admin == 1
      project = Project.new
      project.name =  params[:pnamec]
      project.domaine_id = @domaine
      project.user_cre = @my_user_id.to_i
      project.save

      add_user_project(project.id)

      add_project_test_folders(project.id, params[:pnamec].to_s)

      add_project_sheets_folders(project.id, params[:pnamec].to_s)

      User.where(:id => @my_user_id).update_all("project_id = '#{project.id}'")
      cookies[:profilloaded] = '0'
	     flash[:pid] = project.id
	      redirect_to controller: 'projects', action: 'index'
    end
  end


  def update
    if @can_manage_project == 1
      pid = params[:pid]
      if params[:delete] != nil
        project = Project.where(:id => pid).first
        if project != nil
          #Userproject.where(:project_id => project.id).delete_all
		  Test.where("domaine_id = #{@domaine} and fiche_id is not null and test_folder_id in (select id from test_folders where domaine_id = #{@domaine} and project_id = #{project.id})").update_all(:fiche_id => nil)
		  TestStep.where("domaine_id = #{@domaine} and atdd_test_id is not null and atdd_test_id in (select tests.id from tests, test_folders where tests.domaine_id = #{@domaine} and test_folders.domaine_id = tests.domaine_id and tests.test_folder_id = test_folders.id and test_folders.project_id = #{project.id})").update_all(:atdd_test_id => nil)
          fiches = Fiche.where("domaine_id = #{@domaine} and project_id = #{project.id}").all
          fiches.each do |fiche|
            fiche.destroy
          end
          User.where(:domaine_id => @domaine, :project_id => project.id).update_all(:project_id => nil)
          TestFolder.where("domaine_id = #{@domaine} and project_id = #{project.id}").update_all("test_folder_father_id = null")
          SheetFolder.where("domaine_id = #{@domaine} and project_id = #{project.id}").update_all("sheet_folder_father_id = null")
          EnvironnementVariable.where("domaine_id = #{@domaine} and project_id = #{project.id}").update_all("init_variable_id = null")
          DataSetVariable.where("domaine_id = #{@domaine} and project_id = #{project.id}").update_all("init_variable_id = null")
          Run.where("domaine_id = #{@domaine} and ((test_id in (select tests.id from tests where test_folder_id in (select test_folders.id from test_folders where test_folders.project_id = #{project.id}))) or (suite_id in (select sheets.id from sheets where sheet_folder_id in (select sheet_folders.id from sheet_folders where sheet_folders.project_id = #{project.id}))))").update_all("run_father_id = null")
          runs = Run.where("domaine_id = #{@domaine} and ((test_id in (select tests.id from tests where test_folder_id in (select test_folders.id from test_folders where test_folders.project_id = #{project.id}))) or (suite_id in (select sheets.id from sheets where sheet_folder_id in (select sheet_folders.id from sheet_folders where sheet_folders.project_id = #{project.id}))))").all
          runs.each do |run|
            run.destroy
          end
          project.destroy
          project = nil
          @selectedproject = User.where(:id => @my_user_id).first.project_id
          if Project.where(:id => @selectedproject).first == nil
            @selectedproject = nil
            redirect_to controller: 'projects', action: 'welcome'
          else
            redirect_to controller: 'projects', action: 'index'
          end
        else
          redirect_to controller: 'projects', action: 'index'
        end
      end

      if params[:valid] != nil
        project = Project.where(:id => pid).first
        if project != nil
          project.name = params[:pname].to_s
          project.description = params[:pdesc].to_s
          project.user_maj = User.where(:id => @my_user_id).first.username
          project.save
          root_test_folder = TestFolder.where(:domaine_id => @domaine, :test_folder_father_id => nil).first
          TestFolder.where(:domaine_id => @domaine, :project_id => project.id, :test_folder_father_id => root_test_folder.id).update_all(:name => params[:pname])
          root_sheet_folder = SheetFolder.where(:domaine_id => @domaine, :sheet_folder_father_id => nil).first
          SheetFolder.where(:domaine_id => @domaine, :project_id => project.id, :sheet_folder_father_id => root_sheet_folder.id).update_all(:name => params[:pname])
          flash[:pid] = project.id
          flash[:ko] = 1
          redirect_to controller: 'projects', action: 'index'
        end
      end
    end

  end


  private

  def add_user_project(project_id)
    userproject = Userproject.new
    userproject.domaine_id = @domaine
    userproject.user_id = @my_user_id.to_i
    userproject.project_id = project_id
    userproject.role_id = Role.where(:domaine_id => @domaine, :name => "admin").first.id
    userproject.save
    projectversion = ProjectVersion.new(:domaine_id => @domaine, :project_id => project_id, :version_id => @currentversion, :locked => 0, :user_cre => @username)
    projectversion.save
  end

  def add_project_test_folders(project_id, namefolder)
    root_test_folder = TestFolder.where(:domaine_id => @domaine, :test_folder_father_id => nil).first
    if root_test_folder == nil
      root_test_folder = TestFolder.new
      root_test_folder.domaine_id = @domaine
      root_test_folder.name = "root"
      root_test_folder.can_be_updated = 0
      root_test_folder.save
    end
	  #normal folder test
    project_test_folder = TestFolder.new
    project_test_folder.domaine_id = @domaine
    project_test_folder.name = namefolder
    project_test_folder.project_id = project_id
    project_test_folder.test_folder_father_id = root_test_folder.id
    project_test_folder.can_be_updated = 0
    project_test_folder.save
	  #ATDD folder test
	  project_test_folder = TestFolder.new
    project_test_folder.domaine_id = @domaine
    project_test_folder.name = namefolder
    project_test_folder.project_id = project_id
    project_test_folder.test_folder_father_id = root_test_folder.id
    project_test_folder.can_be_updated = 0
    project_test_folder.is_atdd = 1
    project_test_folder.save
  end

  def add_project_sheets_folders(project_id, namefolder)
    root_sheet_folder = SheetFolder.where(:domaine_id => @domaine, :sheet_folder_father_id => nil).first
    if root_sheet_folder == nil
      root_sheet_folder = SheetFolder.new
      root_sheet_folder.domaine_id = @domaine
      root_sheet_folder.name = "root"
      root_sheet_folder.can_be_updated = 0
      root_sheet_folder.save
    end
	  #folder schéma applicatif
    project_sheet_folder = SheetFolder.new
    project_sheet_folder.domaine_id = @domaine
    project_sheet_folder.type_sheet = 'conception_sheet'
    project_sheet_folder.name = namefolder
    project_sheet_folder.project_id = project_id
    project_sheet_folder.sheet_folder_father_id = root_sheet_folder.id
    project_sheet_folder.can_be_updated = 0
    project_sheet_folder.save
    #folder pour suite de test
    project_sheet_folder = SheetFolder.new
    project_sheet_folder.domaine_id = @domaine
    project_sheet_folder.type_sheet = 'test_suite'
    project_sheet_folder.name = namefolder
    project_sheet_folder.project_id = project_id
    project_sheet_folder.sheet_folder_father_id = root_sheet_folder.id
    project_sheet_folder.can_be_updated = 0
    project_sheet_folder.save
  end

end
