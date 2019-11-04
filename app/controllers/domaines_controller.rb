class DomainesController < ApplicationController
  before_action :require_login


  def index
    if @username == "superadmin"
      @message = nil
      @dom_name = params[:dom_names].to_s
      dom_id = params[:dom_id]
      @domaine = nil
      if @dom_name != ""
        domaines = Domaine.select("domaines.*, users.login as admin_login, users.id as admin_id").joins(" INNER JOIN users on users.domaine_id = domaines.id and users.is_admin = 1").where("users.username like '%#{@dom_name}%' or users.login like '%#{@dom_name}%'" ).order("users.login").all
      else
        domaines = Domaine.select("domaines.*, users.login as admin_login, users.id as admin_id").joins(" INNER JOIN users on users.domaine_id = domaines.id and users.is_admin = 1").order("users.login").all
      end

      @domaines = []
      domaines.each do |domaine|
        @domaines << [domaine.id, domaine.admin_login]
      end

      if dom_id != nil
        if params[:kop].to_s == '0'
          @message = I18n.t "message.maj_effectuee"
          @OK = true
        end
        domaine = Domaine.where(:id => dom_id).first
        admin = User.where(:domaine_id => domaine.id, :is_admin => 1).first
        @domaine = [domaine.id, admin.id, admin.login, admin.email, admin.locked]
      end
    else
      redirect_to controller: 'projects', action: 'welcome', f: 1
    end
  end


  def new
    if @username == "superadmin"
      dom_id, admin_id = License.createdomaine(params[:newlogin])
      redirect_to controller: 'domaines', action: 'index', dom_id: dom_id
    else
      redirect_to controller: 'projects', action: 'welcome'
    end
  end


  def update
    if @username == "superadmin"
      dom_id = params["dom_id"]
      admin_id = params["admin_id"].to_i
      pwd = params["pwd"].to_s
	    email = params["email"].to_s
		locked = params["locked"]
	    user = User.where(:id => admin_id).first
      if params["valid"] != nil
  		  if pwd != "no change!"
  			     _encryptedpassword = Commun.get_encrypted_password(pwd)
  			     user.pwd = _encryptedpassword[0..49]
  		  end
		  if locked == nil then user.locked = 0 else user.locked = 1 end
  		  user.email = email
  		  user.save
  		  redirect_to controller: 'domaines', action: 'index', dom_id: dom_id, kop: 0
      end
  	  if params["delete"] != nil
    		Lockobject.where(:domaine_id => dom_id).delete_all
    		LinkObjVersion.where(:domaine_id => dom_id).delete_all
    		RequiredGem.where(:domaine_id => dom_id).delete_all
    		FicheLink.where(:domaine_id => dom_id).delete_all
    		FicheHisto.where(:domaine_id => dom_id).delete_all
    		FicheDownload.where(:domaine_id => dom_id).delete_all
    		FicheCustoField.where(:domaine_id => dom_id).delete_all
    		Test.where("domaine_id = #{dom_id} and fiche_id is not null").update_all(:fiche_id => nil)
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
    		redirect_to controller: 'domaines', action: 'index'
  	  end

    else
      redirect_to controller: 'projects', action: 'welcome'
    end
  end


end
