
class EnvironnementVariablesController < ApplicationController
  before_action :require_login
  

 
  def index
    envone = (params["envone"]!= nil ? params["envone"] : flash["envone"]).to_s
    envtwo = (params["envtwo"]!= nil ? params["envtwo"] : flash["envtwo"]).to_s
    
    @message=params[:message]
    if params[:ok].to_s == 'ko'
      @OK = false
    else
      @OK = true
    end
    @name = params["name"].to_s
    @description = params["description"].to_s
    filter = ""
    if @name != ""
      filter += " and environnement_variables.name like '%#{@name}%'"
    end
    if @description != ""
      filter += " and environnement_variables.description like '%#{@description}%'"
    end
    
    @envone = nil
    @envtwo = nil
    if envone != ""
      @envone = Environnement.where("id = #{envone}").first
    else
      @envone = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @envone != nil then envone = @envone.id end
    end
    if envtwo != ""
      @envtwo = Environnement.where("id = #{envtwo}").first
    end

    @environnements = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    @environnementvariables = nil

    if @envone != nil and @envtwo == nil
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{@envone.id} and envone.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null #{filter}").order("environnement_variables.name").all
    end	
    if @envone != nil and @envtwo != nil
      if params[:do].to_s == "paste"
        envtwo_variables = EnvironnementVariable.where("domaine_id = #{@domaine} and project_id=#{@selectedproject} and environnement_id = #{@envtwo.id}").all
        envtwo_variables.each do |envtwo_variable|
          envone_variable = EnvironnementVariable.where("domaine_id = #{@domaine} and project_id=#{@selectedproject} and environnement_id = #{@envone.id} and init_variable_id = #{envtwo_variable.init_variable_id}").first
          envtwo_variable.value = envone_variable.value
          envtwo_variable.save
        end
      end
      
      @environnementvariables = EnvironnementVariable
      .select("environnement_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo")
      .joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{@envone.id} and envone.init_variable_id = environnement_variables.id")
      .joins("INNER JOIN environnement_variables as envtwo on envtwo.domaine_id = environnement_variables.domaine_id and envtwo.environnement_id = #{@envtwo.id} and envtwo.init_variable_id = environnement_variables.id ")
      .where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null #{filter}").order("environnement_variables.name").all
    end	
  end  

  def getone
    flash[:envone] = params[:envone].to_s
    redirect_to controller: 'environnement_variables', action: 'index'
  end
  
  def create
    envone = (params["envone"]!= nil ? params["envone"] : flash["envone"]).to_s
    envtwo = (params["envtwo"]!= nil ? params["envtwo"] : flash["envtwo"]).to_s
    @message=nil
    name = params["name"].to_s
    description = params["description"].to_s
    
    nom_variable_existant = false
    first_env_on_version = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
    if first_env_on_version != nil then envid = first_env_on_version.id else envid = nil end
    stringvariable = Commun.get_variables_string
    if stringvariable.index(name + "$") != nil or
        name.start_with? "$domelement" or
        EnvironnementVariable.where(:domaine_id => @domaine, :environnement_id => envid, :name => name).first != nil  or
        DataSetVariable.where(:domaine_id => @domaine, :data_set_id => nil, :init_variable_id => nil, :name => name).first != nil  or
        ConfigurationVariable.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil or 
        TestConstante.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil then
      nom_variable_existant = true
    end
    
    
    if nom_variable_existant == false
      environnementvariable = EnvironnementVariable.new
      environnementvariable.init_variable_id = nil
      environnementvariable.value = nil
      environnementvariable.name = name
      environnementvariable.description = description
      environnementvariable.domaine_id = @domaine
      environnementvariable.project_id = @selectedproject
      environnementvariable.environnement_id = nil
      environnementvariable.is_used = 0
      environnementvariable.is_numeric = 0
      environnementvariable.is_boolean = 0
      environnementvariable.save
      environnements = Environnement.where(:domaine_id => @domaine, :version_id => @selectedversion).all
      if environnements != nil
        environnements.each do |environnement|
          variable = EnvironnementVariable.where(:domaine_id => @domaine, :environnement_id => environnement.id, :init_variable_id =>  environnementvariable.id).first
          if variable == nil
            variable = EnvironnementVariable.new
            variable.init_variable_id = environnementvariable.id
            variable.value = nil
            variable.name = name
            variable.description = description
            variable.domaine_id = @domaine
            variable.project_id = @selectedproject
            variable.environnement_id = environnement.id
            variable.is_used =0
            variable.save
          else
            variable.name = name
            variable.description = description
            variable.save
          end
        end
      end
    else
      @message = (I18n.t "message.nom_existant").gsub("{1}", name)
    end

    @envone = nil
    @envtwo = nil
    if envone != ""
      @envone = Environnement.where("id = #{envone}").first
    else
      @firstenv = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @firstenv != nil then firstenv = @firstenv.id else firstenv = 0 end
    end
    if envtwo != ""
      @envtwo = Environnement.where("id = #{envtwo}").first
    end
    @environnements = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    if @envone == nil  
      @environnementvariable = environnementvariable
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{firstenv} and envone.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null ").order("environnement_variables.name").all
    end
    if @envone != nil and @envtwo == nil
      if environnementvariable == nil
        @environnementvariable = nil
      else
        @environnementvariable = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{envone} and envone.init_variable_id = environnement_variables.id ").where("environnement_variables.id = #{environnementvariable.id}").first
      end
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{envone} and envone.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null ").order("environnement_variables.name").all
    end	
    if @envone != nil and @envtwo != nil
      if environnementvariable == nil
        @environnementvariable = nil
      else
        @environnementvariable = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{envone} and envone.init_variable_id = environnement_variables.id INNER JOIN environnement_variables as envtwo on envtwo.domaine_id = environnement_variables.domaine_id and envtwo.environnement_id = #{envtwo} and envtwo.init_variable_id = environnement_variables.id ").where("environnement_variables.id = #{environnementvariable.id}").first
      end
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{envone} and envone.init_variable_id = environnement_variables.id INNER JOIN environnement_variables as envtwo on envtwo.domaine_id = environnement_variables.domaine_id and envtwo.environnement_id = #{envtwo} and envtwo.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null ").order("environnement_variables.name").all
    end	
  
    respond_to do |format|
      if @environnementvariable !=nil 
        format.html { redirect_to @environnementvariable, notice: 'DOMelement was successfully created.' }
        format.js   {}
        format.json { render json: @environnementvariable, status: :created, location: @environnementvariable }
      else
        format.html { redirect_to  controller: 'environnement_variables', action: 'index'  , message: @message, ok: 'ko' }
        format.json { render json: @environnementvariable.errors, status: :unprocessable_entity }
      end
    end

  end


  def destroy
    envone = (params["envone"]!= nil ? params["envone"] : flash["envone"]).to_s
    envtwo = (params["envtwo"]!= nil ? params["envtwo"] : flash["envtwo"]).to_s
  	@message=nil
		@environnementvariable = EnvironnementVariable.where(:id => params[:id]).first
    if @environnementvariable != nil
      EnvironnementVariable.where(:domaine_id => @domaine, :init_variable_id => @environnementvariable.id).delete_all
      @environnementvariable.destroy
    end

    @envone = nil
    @envtwo = nil
    if envone != ""
      @envone = Environnement.where("id = #{envone}").first
    else
      @firstenv = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @firstenv != nil then firstenv = @firstenv.id else firstenv = 0 end
    end
    if envtwo != ""
      @envtwo = Environnement.where("id = #{envtwo}").first
    end
    @environnements = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    if @envone == nil 
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{firstenv} and envone.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null ").order("environnement_variables.name").all
    end
    if @envone != nil and @envtwo == nil
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{envone} and envone.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null ").order("environnement_variables.name").all
    end	
    if @envone != nil and @envtwo != nil
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{envone} and envone.init_variable_id = environnement_variables.id INNER JOIN environnement_variables as envtwo on envtwo.domaine_id = environnement_variables.domaine_id and envtwo.environnement_id = #{envtwo} and envtwo.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null ").order("environnement_variables.name").all
    end	
  end
  
  def update
    @message=nil
    idelement = params["idelement"]
    @majid = idelement
    name = params["name"]
    description = params["description"]
    @envone = nil
    @envtwo = nil
    envone = params["envone"].to_s
    valueone = params["valueone"].to_s  
    envtwo = params["envtwo"].to_s
    valuetwo = params["valuetwo"].to_s  
    @name = params["filtername"].to_s
    @description = params["filterdesc"].to_s
    is_numeric = 0
    is_boolean = 0
    if params[:isn] != nil 
      is_numeric = 1 
      valueone = valueone.to_f.to_s
      valuetwo = valuetwo.to_f.to_s
    end
    if params[:isb] != nil  
	    is_boolean = 1 
      if valueone != "true" and valueone != "false"
        valueone = "true"
      end
      if valuetwo != "true" and valuetwo != "false"
        valuetwo = "true"
      end
    end
	
    filter = ""
    if @name != ""
      filter += " and environnement_variables.name like '%#{@name}%'"
    end
    if @description != ""
      filter += " and environnement_variables.description like '%#{@description}%'"
    end

    if envone != ""
      @envone = Environnement.where("id = #{envone}").first
    else
      @firstenv = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @firstenv != nil then firstenv = @firstenv.id else firstenv = 0 end
    end
    if envtwo != ""
      @envtwo = Environnement.where("id = #{envtwo}").first
    end
    
    @environnementvariable = EnvironnementVariable.where(:id => idelement).first
    nom_variable_existant = false
    if @environnementvariable.name != name
      first_env_on_version = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if first_env_on_version != nil then envid = first_env_on_version.id else envid = 0 end
      stringvariable = Commun.get_variables_string
      if stringvariable.index(name + "$") != nil or
          name.start_with? "$domelement" or
          EnvironnementVariable.where("domaine_id = #{@domaine} and environnement_id = #{envid} and name = '#{name}' and init_variable_id != #{@environnementvariable.id}").first != nil  or
          ConfigurationVariable.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil  or 
          DataSetVariable.where(:domaine_id => @domaine, :data_set_id => nil, :init_variable_id => nil, :name => name).first != nil  or
          TestConstante.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil then
        nom_variable_existant = true
      end
    end
    if @environnementvariable != nil and nom_variable_existant == false 
      if @environnementvariable.name != name or @environnementvariable.description != description or @environnementvariable.is_numeric != is_numeric or @environnementvariable.is_boolean != is_boolean
        @environnementvariable.name = name
        @environnementvariable.description = description
        @environnementvariable.is_numeric = is_numeric
        @environnementvariable.is_boolean = is_boolean
        @environnementvariable.save
        EnvironnementVariable.where(:domaine_id => @domaine, :init_variable_id =>  @environnementvariable.id).update_all("name = '#{name}', description = '#{description}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      end
      @message = I18n.t "message.maj_effectuee"
      @OK=true
    else
	    if nom_variable_existant  
        @message = (I18n.t "message.nom_existant").gsub("{1}", name)
      else
        @message = I18n.t "message.operation_impossible"
      end
      @OK=false
    end
    
    @environnements = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all
    if @envone == nil 
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{firstenv} and envone.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null #{filter}").order("environnement_variables.name").all
    end
    if @envone != nil and @envtwo == nil
      EnvironnementVariable.where(:domaine_id => @domaine, :init_variable_id =>  @environnementvariable.id, :environnement_id => envone).update_all("value = '#{valueone}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{envone} and envone.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null #{filter}").order("environnement_variables.name").all
    end	
    if @envone != nil and @envtwo != nil
      EnvironnementVariable.where(:domaine_id => @domaine, :init_variable_id =>  @environnementvariable.id, :environnement_id => envone).update_all("value = '#{valueone}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      EnvironnementVariable.where(:domaine_id => @domaine, :init_variable_id =>  @environnementvariable.id, :environnement_id => envtwo).update_all("value = '#{valuetwo}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      @environnementvariables = EnvironnementVariable.select("environnement_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo").joins("INNER JOIN environnement_variables as envone on envone.domaine_id = environnement_variables.domaine_id and envone.environnement_id = #{envone} and envone.init_variable_id = environnement_variables.id INNER JOIN environnement_variables as envtwo on envtwo.domaine_id = environnement_variables.domaine_id and envtwo.environnement_id = #{envtwo} and envtwo.init_variable_id = environnement_variables.id ").where("environnement_variables.domaine_id = #{@domaine} and environnement_variables.project_id=#{@selectedproject} and environnement_variables.environnement_id is null #{filter}").order("environnement_variables.name").all
    end	
  end  
  

end