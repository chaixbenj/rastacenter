
class EnvironnementsController < ApplicationController
  before_action :require_login
  

 
  def index
    @message=params[:message]
    if params[:ok].to_s == 'ko'
      @OK = false
    else
      @OK = true
    end
    name = params["name"].to_s
    description = params["description"].to_s
    filter = ""
    if name != ""
      filter += " and name like '%#{name}%'"
    end
    if description != ""
      filter += " and description like '%#{description}%'"
    end
    @environnements = Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}   #{filter}").all
  end  
  
  def create
    @message=nil
    name = params["name"].to_s
    description = params["description"].to_s
    if Environnement.where("domaine_id = #{@domaine}  and version_id = #{@selectedversion} and name = '#{name}'").first == nil
      @environnement = Environnement.new
      @environnement.name = name
      @environnement.description = description
      @environnement.domaine_id = @domaine
      @environnement.version_id = @currentversion
      @environnement.save
      @environnement.current_id = @environnement.id
      @environnement.save
      configuration_variable_env = ConfigurationVariable.where(:name => '$environment', :domaine_id => @domaine).first
      if configuration_variable_env != nil
        configuration_variable_value = ConfigurationVariableValue.where(:configuration_variable_id => configuration_variable_env.id, :domaine_id => @domaine, :value => name).first
        if configuration_variable_value == nil
          configuration_variable_value = ConfigurationVariableValue.new
          configuration_variable_value.domaine_id = @domaine
          configuration_variable_value.configuration_variable_id = configuration_variable_env.id
          configuration_variable_value.value = name
          configuration_variable_value.is_modifiable = 0
          configuration_variable_value.save
        end
      end

      other_env_on_version = Environnement.where("domaine_id = #{@domaine}  and version_id = #{@selectedversion} and id != #{@environnement.id}").first 
      if other_env_on_version != nil
      environnementvariables = EnvironnementVariable.where("domaine_id = #{@domaine}  and environnement_id = #{other_env_on_version.id}").all
      if environnementvariables != nil
        environnementvariables.each do |environnementvariable|
          variable = environnementvariable.dup
          variable.value = nil
          variable.environnement_id = @environnement.id
          variable.save
        end
      end
      end
    else
      @message = (I18n.t "message.nom_existant").gsub("{1}", name)
    end
    @environnements = Environnement.where(:domaine_id => @domaine, :version_id => @selectedversion).all
  
    respond_to do |format|
      if @environnement !=nil 
        format.html { redirect_to @environnement, notice: 'Environnement was successfully created.' }
        format.js   {}
        format.json { render json: @environnement, status: :created, location: @environnement }
      else
        format.html { redirect_to  controller: 'environnements', action: 'index'  , message: @message, ok: 'ko' }
        format.json { render json: @environnement.errors, status: :unprocessable_entity }
      end
    end

  end


  def destroy
  	@message=nil
		@environnement = Environnement.where(:id => params[:id]).first
    name = @environnement.name
    if @environnement != nil
      @environnement.destroy
      init_env_vars = EnvironnementVariable.where(:domaine_id => @domaine, :environnement_id => nil).all
      init_env_vars.each do |init_env_var|
        if EnvironnementVariable.where(:domaine_id => @domaine, :init_variable_id => init_env_var.id).first == nil
          init_env_var.destroy
        end
      end
      other_env_with_name = Environnement.where("domaine_id = #{@domaine} and name != \"#{name}\"").first 
      if other_env_with_name == nil
        configuration_variable_env = ConfigurationVariable.where(:domaine_id => @domaine, :name => '$environment').first
        if configuration_variable_env != nil
          ConfigurationVariableValue.where(:domaine_id => @domaine, :configuration_variable_id => configuration_variable_env.id, :value => name).delete_all
        end
      end
    end
    @environnements = Environnement.where(:domaine_id => @domaine, :version_id => @selectedversion).all
  end
  
  def update
    @message=nil
    idelement = params["idelement"]
    @majid = idelement
    name = params["name"]
    description = params["description"]
    
    @environnement = Environnement.where(:id => idelement).first
    name_before = @environnement.name
    name_exists = false
    if name_before != name
      if Environnement.where("domaine_id = #{@domaine} and version_id = #{@selectedversion} and name = '#{name}' and id != #{idelement}").first != nil
        name_exists = true
      end
    end
    if @environnement != nil and name_exists == false
      oldname = @environnement.name
      Environnement.where(:domaine_id => @domaine, :name => oldname).update_all(:name => name, :description => description)
      @environnements = Environnement.where(:domaine_id => @domaine, :version_id => @selectedversion).all
      @majid = @environnement.id
      @message = I18n.t "message.maj_effectuee"
      @OK=true
      configuration_variable_env = ConfigurationVariable.where(:name => '$environment', :domaine_id => @domaine).first
      if configuration_variable_env != nil
        configuration_variable_value = ConfigurationVariableValue.where(:configuration_variable_id => configuration_variable_env.id, :domaine_id => @domaine, :value => name_before).first
        if configuration_variable_value == nil
          configuration_variable_value = ConfigurationVariableValue.new
          configuration_variable_value.domaine_id = @domaine
          configuration_variable_value.configuration_variable_id = configuration_variable_env.id
          configuration_variable_value.value = name
          configuration_variable_value.is_modifiable = 0
          configuration_variable_value.save
        else
          configuration_variable_value.value = name
          configuration_variable_value.save
        end
      end
    else
      @environnements = Environnement.where(:domaine_id => @domaine, :version_id => @selectedversion).all
      @message = I18n.t "message.operation_impossible"
      @OK=false
    end
  end  
  


  
end