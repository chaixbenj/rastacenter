
class DataSetVariablesController < ApplicationController
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
      filter += " and data_set_variables.name like '%#{@name}%'"
    end
    if @description != ""
      filter += " and data_set_variables.description like '%#{@description}%'"
    end
    @envone = nil
    @envtwo = nil
    if envone != ""
      @envone = DataSet.where("id = #{envone}").first
    else
      @envone = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @envone != nil then envone = @envone.id end
    end
    if envtwo != ""
      @envtwo = DataSet.where("id = #{envtwo}").first
    end

    @data_sets = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    @data_set_variables = nil

    if @envone != nil and @envtwo == nil
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{@envone.id} and envone.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null #{filter}").order("data_set_variables.name").all
    end	
    if @envone != nil and @envtwo != nil
      if params[:do].to_s == "paste"
        envtwo_variables = DataSetVariable.where("domaine_id = #{@domaine} and project_id=#{@selectedproject} and data_set_id = #{@envtwo.id}").all
        envtwo_variables.each do |envtwo_variable|
          envone_variable = DataSetVariable.where("domaine_id = #{@domaine} and project_id=#{@selectedproject} and data_set_id = #{@envone.id} and init_variable_id = #{envtwo_variable.init_variable_id}").first
          envtwo_variable.value = envone_variable.value
          envtwo_variable.save
        end
      end
      
      @data_set_variables = DataSetVariable
      .select("data_set_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo")
      .joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{@envone.id} and envone.init_variable_id = data_set_variables.id")
      .joins("INNER JOIN data_set_variables as envtwo on envtwo.domaine_id = data_set_variables.domaine_id and envtwo.data_set_id = #{@envtwo.id} and envtwo.init_variable_id = data_set_variables.id ")
      .where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null #{filter}").order("data_set_variables.name").all
    end	
  end  

  def getone
    flash[:envone] = params[:envone].to_s
    redirect_to controller: 'data_set_variables', action: 'index'
  end
  
  def create
    envone = (params["envone"]!= nil ? params["envone"] : flash["envone"]).to_s
    envtwo = (params["envtwo"]!= nil ? params["envtwo"] : flash["envtwo"]).to_s
    @message=nil
    name = params["name"].to_s
    description = params["description"].to_s
    
    nom_variable_existant = false
    first_env_on_version = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
    if first_env_on_version != nil then envid = first_env_on_version.id else envid = nil end
    stringvariable = Commun.get_variables_string
    if stringvariable.index(name + "$") != nil or
        name.start_with? "$domelement" or
        DataSetVariable.where(:domaine_id => @domaine, :data_set_id => envid, :name => name).first != nil  or
        EnvironnementVariable.where(:domaine_id => @domaine, :environnement_id => nil, :init_variable_id => nil, :name => name).first != nil  or
        ConfigurationVariable.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil or 
        TestConstante.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil then
      nom_variable_existant = true
    end
    
    
    if nom_variable_existant == false
      data_set_variable = DataSetVariable.new
      data_set_variable.init_variable_id = nil
      data_set_variable.value = nil
      data_set_variable.name = name
      data_set_variable.description = description
      data_set_variable.domaine_id = @domaine
      data_set_variable.project_id = @selectedproject
      data_set_variable.data_set_id = nil
      data_set_variable.is_used = 0
      data_set_variable.is_numeric = 0
      data_set_variable.is_boolean = 0
      data_set_variable.save
      data_sets = DataSet.where(:domaine_id => @domaine, :version_id => @selectedversion).all
      if data_sets != nil
        data_sets.each do |data_set|
          variable = DataSetVariable.where(:domaine_id => @domaine, :data_set_id => data_set.id, :init_variable_id =>  data_set_variable.id).first
          if variable == nil
            variable = DataSetVariable.new
            variable.init_variable_id = data_set_variable.id
            variable.value = nil
            variable.name = name
            variable.description = description
            variable.domaine_id = @domaine
            variable.project_id = @selectedproject
            variable.data_set_id = data_set.id
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
      @envone = DataSet.where("id = #{envone}").first
    else
      @firstenv = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @firstenv != nil then firstenv = @firstenv.id else firstenv = 0 end
    end
    if envtwo != ""
      @envtwo = DataSet.where("id = #{envtwo}").first
    end
    @data_sets = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    if @envone == nil  
      @data_set_variable = data_set_variable
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{firstenv} and envone.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null ").order("data_set_variables.name").all
    end
    if @envone != nil and @envtwo == nil
      if data_set_variable == nil
        @data_set_variable = nil
      else
        @data_set_variable = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{envone} and envone.init_variable_id = data_set_variables.id ").where("data_set_variables.id = #{data_set_variable.id}").first
      end
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{envone} and envone.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null ").order("data_set_variables.name").all
    end	
    if @envone != nil and @envtwo != nil
      if data_set_variable == nil
        @data_set_variable = nil
      else
        @data_set_variable = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{envone} and envone.init_variable_id = data_set_variables.id INNER JOIN data_set_variables as envtwo on envtwo.domaine_id = data_set_variables.domaine_id and envtwo.data_set_id = #{envtwo} and envtwo.init_variable_id = data_set_variables.id ").where("data_set_variables.id = #{data_set_variable.id}").first
      end
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{envone} and envone.init_variable_id = data_set_variables.id INNER JOIN data_set_variables as envtwo on envtwo.domaine_id = data_set_variables.domaine_id and envtwo.data_set_id = #{envtwo} and envtwo.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null ").order("data_set_variables.name").all
    end	
  
    respond_to do |format|
      if @data_set_variable !=nil 
        format.html { redirect_to @data_set_variable, notice: 'DOMelement was successfully created.' }
        format.js   {}
        format.json { render json: @data_set_variable, status: :created, location: @data_set_variable }
      else
        format.html { redirect_to  controller: 'data_set_variables', action: 'index'  , message: @message, ok: 'ko' }
        format.json { render json: @data_set_variable.errors, status: :unprocessable_entity }
      end
    end

  end


  def destroy
    envone = (params["envone"]!= nil ? params["envone"] : flash["envone"]).to_s
    envtwo = (params["envtwo"]!= nil ? params["envtwo"] : flash["envtwo"]).to_s
  	@message=nil
		@data_set_variable = DataSetVariable.where(:id => params[:id]).first
    if @data_set_variable != nil
      DataSetVariable.where(:domaine_id => @domaine, :init_variable_id => @data_set_variable.id).delete_all
      @data_set_variable.destroy
    end
    
    @envone = nil
    @envtwo = nil
    if envone != ""
      @envone = DataSet.where("id = #{envone}").first
    else
      @firstenv = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @firstenv != nil then firstenv = @firstenv.id else firstenv = 0 end
    end
    if envtwo != ""
      @envtwo = DataSet.where("id = #{envtwo}").first
    end
    @data_sets = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    if @envone == nil 
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{firstenv} and envone.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null ").order("data_set_variables.name").all
    end
    if @envone != nil and @envtwo == nil
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{envone} and envone.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null ").order("data_set_variables.name").all
    end	
    if @envone != nil and @envtwo != nil
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{envone} and envone.init_variable_id = data_set_variables.id INNER JOIN data_set_variables as envtwo on envtwo.domaine_id = data_set_variables.domaine_id and envtwo.data_set_id = #{envtwo} and envtwo.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null ").order("data_set_variables.name").all
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
      filter += " and data_set_variables.name like '%#{@name}%'"
    end
    if @description != ""
      filter += " and data_set_variables.description like '%#{@description}%'"
    end

    if envone != ""
      @envone = DataSet.where("id = #{envone}").first
    else
      @firstenv = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @firstenv != nil then firstenv = @firstenv.id else firstenv = 0 end
    end
    if envtwo != ""
      @envtwo = DataSet.where("id = #{envtwo}").first
    end
    
    @data_set_variable = DataSetVariable.where(:id => idelement).first
    nom_variable_existant = false
    if @data_set_variable.name != name
      first_env_on_version = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if first_env_on_version != nil then envid = first_env_on_version.id else envid = 0 end
      stringvariable = Commun.get_variables_string
      if stringvariable.index(name + "$") != nil or
          name.start_with? "$domelement" or
          DataSetVariable.where("domaine_id = #{@domaine} and data_set_id = #{envid} and name = '#{name}' and init_variable_id != #{@data_set_variable.id}").first != nil  or
          ConfigurationVariable.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil  or
          EnvironnementVariable.where(:domaine_id => @domaine, :environnement_id => nil, :init_variable_id => nil, :name => name).first != nil  or		  
          TestConstante.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil then
        nom_variable_existant = true
      end
    end
    if @data_set_variable != nil and nom_variable_existant == false 
      if @data_set_variable.name != name or @data_set_variable.description != description or @data_set_variable.is_numeric != is_numeric or @data_set_variable.is_boolean != is_boolean
        @data_set_variable.name = name
        @data_set_variable.description = description
        @data_set_variable.is_numeric = is_numeric
        @data_set_variable.is_boolean = is_boolean
        @data_set_variable.save
        DataSetVariable.where(:domaine_id => @domaine, :init_variable_id =>  @data_set_variable.id).update_all("name = '#{name}', description = '#{description}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
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
    
    @data_sets = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all
    if @envone == nil 
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{firstenv} and envone.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null #{filter}").order("data_set_variables.name").all
    end
    if @envone != nil and @envtwo == nil
      DataSetVariable.where(:domaine_id => @domaine, :init_variable_id =>  @data_set_variable.id, :data_set_id => envone).update_all("value = '#{valueone}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{envone} and envone.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null #{filter}").order("data_set_variables.name").all
    end	
    if @envone != nil and @envtwo != nil
      DataSetVariable.where(:domaine_id => @domaine, :init_variable_id =>  @data_set_variable.id, :data_set_id => envone).update_all("value = '#{valueone}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      DataSetVariable.where(:domaine_id => @domaine, :init_variable_id =>  @data_set_variable.id, :data_set_id => envtwo).update_all("value = '#{valuetwo}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      @data_set_variables = DataSetVariable.select("data_set_variables.*, envone.value as valueone, envone.id as idvarone, envtwo.value as valuetwo, envtwo.id as idvartwo").joins("INNER JOIN data_set_variables as envone on envone.domaine_id = data_set_variables.domaine_id and envone.data_set_id = #{envone} and envone.init_variable_id = data_set_variables.id INNER JOIN data_set_variables as envtwo on envtwo.domaine_id = data_set_variables.domaine_id and envtwo.data_set_id = #{envtwo} and envtwo.init_variable_id = data_set_variables.id ").where("data_set_variables.domaine_id = #{@domaine} and data_set_variables.project_id=#{@selectedproject} and data_set_variables.data_set_id is null #{filter}").order("data_set_variables.name").all
    end	
  end  
  
end