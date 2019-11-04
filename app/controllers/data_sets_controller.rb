
class DataSetsController < ApplicationController
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
     
    @data_sets = DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}   #{filter}").all
  end  
  
  def create
    @message=nil
    name = params["name"].to_s
    description = params["description"].to_s
    if DataSet.where("domaine_id = #{@domaine}  and version_id = #{@selectedversion} and name = '#{name}'").first == nil
      @data_set = DataSet.new
      @data_set.name = name
      @data_set.description = description
      @data_set.domaine_id = @domaine
      @data_set.version_id = @currentversion
	  @data_set.is_default = 0
      @data_set.save
      @data_set.current_id = @data_set.id
      @data_set.save
      configuration_variable_env = ConfigurationVariable.where(:name => '$data_set', :domaine_id => @domaine).first
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

      other_env_on_version = DataSet.where("domaine_id = #{@domaine}  and version_id = #{@selectedversion} and id != #{@data_set.id}").first 
      if other_env_on_version != nil
      data_setvariables = DataSetVariable.where("domaine_id = #{@domaine}  and data_set_id = #{other_env_on_version.id}").all
      if data_setvariables != nil
        data_setvariables.each do |data_setvariable|
          variable = data_setvariable.dup
          variable.value = nil
          variable.data_set_id = @data_set.id
          variable.save
        end
      end
      end
    else
      @message = (I18n.t "message.nom_existant").gsub("{1}", name)
    end
    @data_sets = DataSet.where(:domaine_id => @domaine, :version_id => @selectedversion).all
  
    respond_to do |format|
      if @data_set !=nil 
        format.html { redirect_to @data_set, notice: 'DataSet was successfully created.' }
        format.js   {}
        format.json { render json: @data_set, status: :created, location: @data_set }
      else
        format.html { redirect_to  controller: 'data_sets', action: 'index'  , message: @message, ok: 'ko' }
        format.json { render json: @data_set.errors, status: :unprocessable_entity }
      end
    end

  end


  def destroy
  	@message=nil
	@data_set = DataSet.where(:id => params[:id]).first
    name = @data_set.name
    if @data_set != nil
      @data_set.destroy
      init_env_vars = DataSetVariable.where(:domaine_id => @domaine, :data_set_id => nil).all
      init_env_vars.each do |init_env_var|
        if DataSetVariable.where(:domaine_id => @domaine, :init_variable_id => init_env_var.id).first == nil
          init_env_var.destroy
        end
      end
	configuration_variable_env = ConfigurationVariable.where(:domaine_id => @domaine, :name => '$data_set').first
	if configuration_variable_env != nil
	  ConfigurationVariableValue.where(:domaine_id => @domaine, :configuration_variable_id => configuration_variable_env.id, :value => name).delete_all
	end
    end
    @data_sets = DataSet.where(:domaine_id => @domaine, :version_id => @selectedversion).all
  end
  
  def update
    @message=nil
    idelement = params["idelement"]
    @majid = idelement
    name = params["name"]
    description = params["description"]
    
    @data_set = DataSet.where(:id => idelement).first
    name_before = @data_set.name
    name_exists = false
    if name_before != name
      if DataSet.where("domaine_id = #{@domaine} and version_id = #{@selectedversion} and name = '#{name}' and id != #{idelement}").first != nil
        name_exists = true
      end
    end
    if @data_set != nil and name_exists == false
      oldname = @data_set.name
      DataSet.where(:domaine_id => @domaine, :name => oldname).update_all(:name => name, :description => description)
      @data_sets = DataSet.where(:domaine_id => @domaine, :version_id => @selectedversion).all
      @majid = @data_set.id
      @message = I18n.t "message.maj_effectuee"
      @OK=true
      configuration_variable_env = ConfigurationVariable.where(:name => '$data_set', :domaine_id => @domaine).first
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
      @data_sets = DataSet.where(:domaine_id => @domaine, :version_id => @selectedversion).all
      @message = I18n.t "message.operation_impossible"
      @OK=false
    end
  end  
  


  
end