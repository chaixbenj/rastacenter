
class AppiumCapsController < ApplicationController
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
     
    @appium_caps = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}   #{filter}").all
  end  
  
  def create
    @message=nil
    name = params["name"].to_s
    description = params["description"].to_s
    if AppiumCap.where("domaine_id = #{@domaine}  and version_id = #{@selectedversion} and name = '#{name}'").first == nil
      @appium_cap = AppiumCap.new
      @appium_cap.name = name
      @appium_cap.description = description
      @appium_cap.version_id = @selectedversion
      @appium_cap.domaine_id = @domaine
      @appium_cap.save
	  @appium_cap.current_id = @appium_cap.id
      @appium_cap.save
      configuration_variable_appium_cap = ConfigurationVariable.where(:name => '$appium_capabilities', :domaine_id => @domaine).first
      if configuration_variable_appium_cap != nil
        configuration_variable_value = ConfigurationVariableValue.where(:configuration_variable_id => configuration_variable_appium_cap.id, :domaine_id => @domaine, :value => name).first
        if configuration_variable_value == nil
          configuration_variable_value = ConfigurationVariableValue.new
          configuration_variable_value.domaine_id = @domaine
          configuration_variable_value.configuration_variable_id = configuration_variable_appium_cap.id
          configuration_variable_value.value = name
          configuration_variable_value.is_modifiable = 0
          configuration_variable_value.save
        end
      end

      other_cap_on_version = AppiumCap.where("domaine_id = #{@domaine}  and version_id = #{@selectedversion} and id != #{@appium_cap.id}").first 
      if other_cap_on_version != nil
      appiumcapvalues = AppiumCapValue.where("domaine_id = #{@domaine}  and appium_cap_id = #{other_cap_on_version.id}").all
      if appiumcapvalues != nil
        appiumcapvalues.each do |appiumcapvalue|
          variable = appiumcapvalue.dup
          variable.value = nil
          variable.appium_cap_id = @appium_cap.id
          variable.save
        end
      end
      end
    else
      @message = (I18n.t "message.nom_existant").gsub("{1}", name)
    end
    @appium_caps = AppiumCap.where(:domaine_id => @domaine, :version_id => @selectedversion).all
  
    respond_to do |format|
      if @appium_cap !=nil 
        format.html { redirect_to @appium_cap, notice: 'AppiumCap was successfully created.' }
        format.js   {}
        format.json { render json: @appium_cap, status: :created, location: @appium_cap }
      else
        format.html { redirect_to  controller: 'appiumcaps', action: 'index'  , message: @message, ok: 'ko' }
        format.json { render json: @appium_cap.errors, status: :unprocessable_entity }
      end
    end

  end


  def destroy
  	@message=nil
		@appium_cap = AppiumCap.where(:id => params[:id]).first
    name = @appium_cap.name
    if @appium_cap != nil
      @appium_cap.destroy
      
      init_cap_vars = AppiumCapValue.where(:domaine_id => @domaine, :appium_cap_id => nil).all
      init_cap_vars.each do |init_cap_var|
        if AppiumCapValue.where(:domaine_id => @domaine, :init_value_id => init_cap_var.id).first == nil
          init_cap_var.destroy
        end
      end
      other_cap_with_name = AppiumCap.where("domaine_id = #{@domaine} and name != \"#{name}\"").first 
      if other_cap_with_name == nil
        
      
      configuration_variable_appium_cap = ConfigurationVariable.where(:domaine_id => @domaine, :name => '$appium_capabilities').first
      if configuration_variable_appium_cap != nil
        ConfigurationVariableValue.where(:domaine_id => @domaine, :configuration_variable_id => configuration_variable_appium_cap.id, :value => name).delete_all
      end
      end
    end
    @appium_caps = AppiumCap.where(:domaine_id => @domaine, :version_id => @selectedversion).all
  end
  
  def update
    @message=nil
    idelement = params["idelement"]
    @majid = idelement
    name = params["name"]
    description = params["description"]
    
    @appium_cap = AppiumCap.where(:id => idelement).first
    name_before = @appium_cap.name
    name_exists = false
    if name_before != name
      if AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion} and name = '#{name}' and id != #{idelement}").first != nil
        name_exists = true
      end
    end
    if @appium_cap != nil and name_exists == false
      oldname = @appium_cap.name
      AppiumCap.where(:domaine_id => @domaine, :name => oldname).update_all(:name => name, :description => description)
      @appium_caps = AppiumCap.where(:domaine_id => @domaine, :version_id => @selectedversion).all
      @majid = @appium_cap.id
      @message = I18n.t "message.maj_effectuee"
      @OK=true
      configuration_variable_appium_cap = ConfigurationVariable.where(:name => '$appium_capabilities', :domaine_id => @domaine).first
      if configuration_variable_appium_cap != nil
        configuration_variable_value = ConfigurationVariableValue.where(:configuration_variable_id => configuration_variable_appium_cap.id, :domaine_id => @domaine, :value => name_before).first
        if configuration_variable_value == nil
          configuration_variable_value = ConfigurationVariableValue.new
          configuration_variable_value.domaine_id = @domaine
          configuration_variable_value.configuration_variable_id = configuration_variable_appium_cap.id
          configuration_variable_value.value = name
          configuration_variable_value.is_modifiable = 0
          configuration_variable_value.save
        else
          configuration_variable_value.value = name
          configuration_variable_value.save
        end
      end
    else
      @appium_caps = AppiumCap.where(:domaine_id => @domaine, :version_id => @selectedversion).all
      @message = I18n.t "message.operation_impossible"
      @OK=false
    end
    #	system('pause')
  end  
  


  
end