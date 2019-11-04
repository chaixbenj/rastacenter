class ConfigurationVariablesController < ApplicationController
  before_action :require_login

  
  def index
    varid = (params[:varid] != nil ? params[:varid] : flash[:varid].to_s).to_s

    @name = params[:sname].to_s
    if @name != ""
      @configurationvariables = ConfigurationVariable.where("domaine_id = #{@domaine} and name like '%#{@name}%'").order(:name).all
    else  
      @configurationvariables = ConfigurationVariable.where("domaine_id = #{@domaine}").order(:name).all
    end 
 
    @message = nil
    
    @message, @OK = Commun.set_message(flash[:ko])
	
	  if varid != ""
      @configurationvariable = ConfigurationVariable.where(:id => varid).first
      if @configurationvariable != nil
        @configurationvariablevalues = ConfigurationVariableValue.where(:configuration_variable_id => varid).all.order(:value)
      end
    end    
  end  
    
  def getone
    flash[:varid] = params[:varid].to_s
    redirect_to controller: 'configuration_variables', action: 'index'
  end
   
  def update
    varid = params[:varid].to_s
    if @can_manage_configuration_variable == 1
      if params[:delete] != nil
        configurationvariable = ConfigurationVariable.where(:id => varid).first
        if configurationvariable != nil 
          #ConfigurationVariableValue.where(:configuration_variable_id => configurationvariable.id).delete_all
          configurationvariable.destroy
        end
      end

      if params[:valid] != nil
        @configurationvariable = ConfigurationVariable.where(:id => varid).first
        flash[:ko] = 1
        if @configurationvariable != nil
          name = params[:name].to_s
          nom_variable_existant = false
          stringvariable = Commun.get_variables_string
          if @configurationvariable.is_deletable == 1 and (stringvariable.index(name + "$") != nil or
                name.start_with? "$domelement" or
                EnvironnementVariable.where("domaine_id = #{@domaine} and environnement_id is null and name = '#{name}'").first != nil  or
                DataSetVariable.where(:domaine_id => @domaine, :data_set_id => nil, :init_variable_id => nil, :name => name).first != nil  or
                ConfigurationVariable.where("domaine_id = #{@domaine} and name = '#{name}' and id != #{varid}").first != nil  or 
                TestConstante.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil) then
            nom_variable_existant = true
          end
          if nom_variable_existant == false
            if @configurationvariable.is_deletable == 1
              if params[:isn] != nil then @configurationvariable.is_numeric = 1 else @configurationvariable.is_numeric = 0 end
              if params[:isb] != nil then @configurationvariable.is_boolean = 1 else @configurationvariable.is_boolean = 0 end
              @configurationvariable.name = params[:name].to_s
            end
            @configurationvariable.description = params[:desc].to_s
            @configurationvariable.save
            nbvalues = params[:nbvalue].to_s.to_i
            for val in 1..nbvalues
              varvalid = params["varvalueid#{val}"]
              varval = params["varvalue#{val}"].to_s
              if varvalid == nil and varval.gsub(" ","") != ""
                variablevalue = ConfigurationVariableValue.new
                variablevalue.domaine_id = @domaine
                variablevalue.is_modifiable = 1
                variablevalue.configuration_variable_id = varid
                variablevalue.value = varval
                if params[:isn] != nil then variablevalue.value = varval.to_f.to_s end
                if params[:isb] != nil then 
                  if varval != "true" and varval != "false"
                    variablevalue.value = ""
                    if val == 1 then variablevalue.value = "true" end
                    if val == 2 then variablevalue.value = "false" end
                  end
                end
                if variablevalue.value != "" then variablevalue.save end
              else
                if varvalid != nil
                  variablevalue = ConfigurationVariableValue.where(:id => varvalid.to_i).first
                  if varval.gsub(" ","") == ""
                    if variablevalue != nil and variablevalue.is_modifiable == 1
                      variablevalue.destroy
                    end
                  else
                    variablevalue.value = varval
                    if params[:isn] != nil then variablevalue.value = varval.to_f.to_s end
                    if params[:isb] != nil then 
                      if varval != "true" and varval != "false"
                        variablevalue.value = ""
                        if val == 1 then variablevalue.value = "true" end
                        if val == 2 then variablevalue.value = "false" end
                      end
                    end
                    if variablevalue.value != "" then variablevalue.save else variablevalue.destroy end
                  end
                end
              end
            end 
          else
            flash[:ko] = 5
          end
          flash[:varid] = @configurationvariable.id
        end     
      end
    end    
	  redirect_to controller: 'configuration_variables', action: 'index'
  end
  
  
  def new
    if @can_manage_configuration_variable == 1
      flash[:ko] = 1
      name = params[:namec].to_s
      nom_variable_existant = false
      stringvariable = Commun.get_variables_string
      if stringvariable.index(name + "$") != nil or
          name.start_with? "$domelement" or
          EnvironnementVariable.where("domaine_id = #{@domaine} and environnement_id is null and name = '#{name}'").first != nil  or
          DataSetVariable.where(:domaine_id => @domaine, :data_set_id => nil, :init_variable_id => nil, :name => name).first != nil  or
          ConfigurationVariable.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil  or 
          TestConstante.where("domaine_id = #{@domaine} and name = '#{name}'").first != nil then
        nom_variable_existant = true
      end
        
      if nom_variable_existant == false
        configurationvariable = ConfigurationVariable.new
        configurationvariable.name =  params[:namec]
        configurationvariable.domaine_id = @domaine
        configurationvariable.is_deletable = 1
        configurationvariable.no_value = 0
        configurationvariable.is_numeric = 0
        configurationvariable.is_boolean = 0
        configurationvariable.save
        flash[:varid] = configurationvariable.id
      else
        flash[:ko] = 5
      end
    end
    redirect_to controller: 'configuration_variables', action: 'index'
  end  
		
end
