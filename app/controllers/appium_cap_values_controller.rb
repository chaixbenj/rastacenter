
class AppiumCapValuesController < ApplicationController
  before_action :require_login
  

 
  def index
    appiumcapone = (params["appiumcapone"]!= nil ? params["appiumcapone"] : flash["appiumcapone"]).to_s
    appiumcaptwo = (params["appiumcaptwo"]!= nil ? params["appiumcaptwo"] : flash["appiumcaptwo"]).to_s
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
      filter += " and appium_cap_values.name like '%#{@name}%'"
    end
    if @description != ""
      filter += " and appium_cap_values.description like '%#{@description}%'"
    end

    @appiumcapone = nil
    @appiumcaptwo = nil
    if appiumcapone != ""
      @appiumcapone = AppiumCap.where("id = #{appiumcapone}").first
    else
      @appiumcapone = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @appiumcapone != nil then appiumcapone = @appiumcapone.id end
    end
    if appiumcaptwo != ""
      @appiumcaptwo = AppiumCap.where("id = #{appiumcaptwo}").first
    end
    
    @appium_caps = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    @appium_cap_values = nil
    
    if @appiumcapone != nil and @appiumcaptwo == nil
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{@appiumcapone.id} and appiumcapone.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null #{filter}").order("appium_cap_values.name").all
    end	
    if @appiumcapone != nil and @appiumcaptwo != nil
      if params[:do].to_s == "paste"
        appiumcaptwo_variables = AppiumCapValue.where("domaine_id = #{@domaine} and appium_cap_id = #{@appiumcaptwo.id}").all
        appiumcaptwo_variables.each do |appiumcaptwo_variable|
          appiumcapone_variable = AppiumCapValue.where("domaine_id = #{@domaine} and appium_cap_id = #{@appiumcapone.id} and init_value_id = #{appiumcaptwo_variable.init_value_id}").first
          appiumcaptwo_variable.value = appiumcapone_variable.value
          appiumcaptwo_variable.save
        end
      end
      
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone, appiumcaptwo.value as valuetwo, appiumcaptwo.id as idvartwo")
      .joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{@appiumcapone.id} and appiumcapone.init_value_id = appium_cap_values.id")
      .joins("INNER JOIN appium_cap_values as appiumcaptwo on appiumcaptwo.domaine_id = appium_cap_values.domaine_id and appiumcaptwo.appium_cap_id = #{appiumcaptwo} and appiumcaptwo.init_value_id = appium_cap_values.id ")
      .where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null #{filter}").order("appium_cap_values.name").all
    end	
  end  

  def getone
    flash[:appiumcapone] = params[:appiumcapone].to_s
    redirect_to controller: 'appium_cap_values', action: 'index'
  end
  
  def create
    appiumcapone = (params["appiumcapone"]!= nil ? params["appiumcapone"] : flash["appiumcapone"]).to_s
    appiumcaptwo = (params["appiumcaptwo"]!= nil ? params["appiumcaptwo"] : flash["appiumcaptwo"]).to_s
    @message=nil
    name = params["name"].to_s
    description = params["description"].to_s
    
    nom_variable_existant = false
    first_cap_on_version = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
    if first_cap_on_version != nil then capid = first_cap_on_version.id else capid = nil end
    if AppiumCapValue.where(:domaine_id => @domaine, :appium_cap_id => capid, :name => name).first != nil   
      nom_variable_existant = true
    end
    
    
    if nom_variable_existant == false
      appium_cap_value = AppiumCapValue.new
      appium_cap_value.init_value_id = nil
      appium_cap_value.value = nil
      appium_cap_value.name = name
      appium_cap_value.description = description
      appium_cap_value.domaine_id = @domaine
      appium_cap_value.appium_cap_id = nil
      appium_cap_value.is_numeric = 0
      appium_cap_value.is_boolean = 0
      appium_cap_value.save
      appium_caps = AppiumCap.where(:domaine_id => @domaine, :version_id => @selectedversion).all
      if appium_caps != nil
        appium_caps.each do |appium_cap|
          variable = AppiumCapValue.where(:domaine_id => @domaine, :appium_cap_id => appium_cap.id, :init_value_id =>  appium_cap_value.id).first
          if variable == nil
            variable = AppiumCapValue.new
            variable.init_value_id = appium_cap_value.id
            variable.value = nil
            variable.name = name
            variable.description = description
            variable.domaine_id = @domaine
            variable.appium_cap_id = appium_cap.id
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

    @appiumcapone = nil
    @appiumcaptwo = nil
    if appiumcapone != ""
      @appiumcapone = AppiumCap.where("id = #{appiumcapone}").first
    else
      @firstappiumcap = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @firstappiumcap != nil then firstappiumcap = @firstappiumcap.id else firstappiumcap = 0 end
    end
    if appiumcaptwo != ""
      @appiumcaptwo = AppiumCap.where("id = #{appiumcaptwo}").first
    end
    @appium_caps = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    if @appiumcapone == nil 
      @appium_cap_value = appium_cap_value
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{firstappiumcap} and appiumcapone.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null").order("appium_cap_values.name").all
    end
    if @appiumcapone != nil and @appiumcaptwo == nil
      if appium_cap_value != nil
        @appium_cap_value = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{appiumcapone} and appiumcapone.init_value_id = appium_cap_values.id ").where("appium_cap_values.id = #{appium_cap_value.id}").first
      else
        @appium_cap_value = appium_cap_value
      end
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{appiumcapone} and appiumcapone.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null").order("appium_cap_values.name").all
    end	
    if @appiumcapone != nil and @appiumcaptwo != nil
      if appium_cap_value != nil
        @appium_cap_value = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone, appiumcaptwo.value as valuetwo, appiumcaptwo.id as idvartwo").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{appiumcapone} and appiumcapone.init_value_id = appium_cap_values.id INNER JOIN appium_cap_values as appiumcaptwo on appiumcaptwo.domaine_id = appium_cap_values.domaine_id and appiumcaptwo.appium_cap_id = #{appiumcaptwo} and appiumcaptwo.init_value_id = appium_cap_values.id ").where("appium_cap_values.id = #{appium_cap_value.id}").first
      else
        @appium_cap_value = appium_cap_value
      end
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone, appiumcaptwo.value as valuetwo, appiumcaptwo.id as idvartwo").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{appiumcapone} and appiumcapone.init_value_id = appium_cap_values.id INNER JOIN appium_cap_values as appiumcaptwo on appiumcaptwo.domaine_id = appium_cap_values.domaine_id and appiumcaptwo.appium_cap_id = #{appiumcaptwo} and appiumcaptwo.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null").order("appium_cap_values.name").all
    end	
  
    respond_to do |format|
      if @appium_cap_value !=nil 
        format.html { redirect_to @appium_cap_value, notice: 'DOMelement was successfully created.' }
        format.js   {}
        format.json { render json: @appium_cap_value, status: :created, location: @appium_cap_value }
      else
        format.html { redirect_to  controller: 'appium_cap_values', action: 'index'  , message: @message, ok: 'ko' }
        format.json { render json: @appium_cap_value.errors, status: :unprocessable_entity }
      end
    end

  end


  def destroy
    appiumcapone = (params["appiumcapone"]!= nil ? params["appiumcapone"] : flash["appiumcapone"]).to_s
    appiumcaptwo = (params["appiumcaptwo"]!= nil ? params["appiumcaptwo"] : flash["appiumcaptwo"]).to_s
  	@message=nil
		@appium_cap_value = AppiumCapValue.where(:id => params[:id]).first
    if @appium_cap_value != nil
      AppiumCapValue.where(:domaine_id => @domaine, :init_value_id => @appium_cap_value.id).delete_all
      @appium_cap_value.destroy
    end

    @appiumcapone = nil
    @appiumcaptwo = nil
    if appiumcapone != ""
      @appiumcapone = AppiumCap.where("id = #{appiumcapone}").first
    else
      @firstappiumcap = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @firstappiumcap != nil then firstappiumcap = @firstappiumcap.id else firstappiumcap = 0 end
    end
    if appiumcaptwo != ""
      @appiumcaptwo = AppiumCap.where("id = #{appiumcaptwo}").first
    end
    @appium_caps = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    if @appiumcapone == nil 
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{firstappiumcap} and appiumcapone.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null ").order("appium_cap_values.name").all
    end
    if @appiumcapone != nil and @appiumcaptwo == nil
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{appiumcapone} and appiumcapone.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null ").order("appium_cap_values.name").all
    end	
    if @appiumcapone != nil and @appiumcaptwo != nil
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone, appiumcaptwo.value as valuetwo, appiumcaptwo.id as idvartwo").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{appiumcapone} and appiumcapone.init_value_id = appium_cap_values.id INNER JOIN appium_cap_values as appiumcaptwo on appiumcaptwo.domaine_id = appium_cap_values.domaine_id and appiumcaptwo.appium_cap_id = #{appiumcaptwo} and appiumcaptwo.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null").order("appium_cap_values.name").all
    end	
  end
  
  def update
    @message=nil
    idelement = params["idelement"]
    @majid = idelement
    name = params["name"]
    description = params["description"]
    @appiumcapone = nil
    @appiumcaptwo = nil
    appiumcapone = params["appiumcapone"].to_s
    valueone = params["valueone"].to_s  
    appiumcaptwo = params["appiumcaptwo"].to_s
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
      filter += " and appium_cap_values.name like '%#{@name}%'"
    end
    if @description != ""
      filter += " and appium_cap_values.description like '%#{@description}%'"
    end
  
    if appiumcapone != ""
      @appiumcapone = AppiumCap.where("id = #{appiumcapone}").first
    else
      @firstappiumcap = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if @firstappiumcap != nil then firstappiumcap = @firstappiumcap.id else firstappiumcap = 0 end
    end
    if appiumcaptwo != ""
      @appiumcaptwo = AppiumCap.where("id = #{appiumcaptwo}").first
    end
      
    @appium_cap_value = AppiumCapValue.where(:id => idelement).first
    nom_variable_existant = false
    if @appium_cap_value.name != name
      first_cap_on_version = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").first
      if first_cap_on_version != nil then capid = first_cap_on_version.id else capid = 0 end
      if AppiumCapValue.where("domaine_id = #{@domaine} and appium_cap_id = #{capid} and name = '#{name}' and init_value_id != #{@appium_cap_value.id}").first != nil then
        nom_variable_existant = true
      end
    end
    
    if @appium_cap_value != nil and nom_variable_existant == false
      if @appium_cap_value.name != name or @appium_cap_value.description != description or @appium_cap_value.is_numeric != is_numeric or @appium_cap_value.is_boolean != is_boolean
        @appium_cap_value.name = name
        @appium_cap_value.description = description
        @appium_cap_value.is_numeric = is_numeric
        @appium_cap_value.is_boolean = is_boolean
        @appium_cap_value.save
        AppiumCapValue.where(:domaine_id => @domaine, :init_value_id =>  @appium_cap_value.id).update_all("name = '#{name}', description = '#{description}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
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

    @appium_caps = AppiumCap.where("domaine_id = #{@domaine} and version_id = #{@selectedversion}").all 
    if @appiumcapone == nil 
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{firstappiumcap} and appiumcapone.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null #{filter}").order("appium_cap_values.name").all
    end
    if @appiumcapone != nil and @appiumcaptwo == nil
      AppiumCapValue.where(:domaine_id => @domaine, :init_value_id =>  @appium_cap_value.id, :appium_cap_id => appiumcapone).update_all("value = '#{valueone}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{appiumcapone} and appiumcapone.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null #{filter}").order("appium_cap_values.name").all
    end	
    if @appiumcapone != nil and @appiumcaptwo != nil
      AppiumCapValue.where(:domaine_id => @domaine, :init_value_id =>  @appium_cap_value.id, :appium_cap_id => appiumcapone).update_all("value = '#{valueone}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      AppiumCapValue.where(:domaine_id => @domaine, :init_value_id =>  @appium_cap_value.id, :appium_cap_id => appiumcaptwo).update_all("value = '#{valuetwo}', is_numeric = #{is_numeric}, is_boolean = #{is_boolean}")
      @appium_cap_values = AppiumCapValue.select("appium_cap_values.*, appiumcapone.value as valueone, appiumcapone.id as idvarone, appiumcaptwo.value as valuetwo, appiumcaptwo.id as idvartwo").joins("INNER JOIN appium_cap_values as appiumcapone on appiumcapone.domaine_id = appium_cap_values.domaine_id and appiumcapone.appium_cap_id = #{appiumcapone} and appiumcapone.init_value_id = appium_cap_values.id INNER JOIN appium_cap_values as appiumcaptwo on appiumcaptwo.domaine_id = appium_cap_values.domaine_id and appiumcaptwo.appium_cap_id = #{appiumcaptwo} and appiumcaptwo.init_value_id = appium_cap_values.id ").where("appium_cap_values.domaine_id = #{@domaine} and appium_cap_values.appium_cap_id is null #{filter}").order("appium_cap_values.name").all
    end	  
  end  
  


  
end