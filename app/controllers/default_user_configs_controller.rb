class DefaultUserConfigsController < ApplicationController
  before_action :require_login

  
  def index
	@message, @OK = Commun.set_message(flash[:ko])
    
    @default_user_configs = 
      ConfigurationVariable.select("configuration_variables.id as variable_id, 
                           configuration_variables.name as variable_name, 
                           configuration_variable_values.value as allowed_value, 
                           default_user_configs.id as user_configs_id, 
                           default_user_configs.variable_value as user_variable_value")
    .joins("INNER JOIN configuration_variable_values 
                            on configuration_variable_values.domaine_id=configuration_variables.domaine_id and configuration_variable_values.configuration_variable_id=configuration_variables.id 
                          LEFT OUTER JOIN default_user_configs 
                            on default_user_configs.domaine_id = configuration_variables.domaine_id and default_user_configs.user_id = #{@my_user_id} and default_user_configs.variable_id = configuration_variables.id")
    .where("configuration_variables.domaine_id = #{@domaine}").all.order("configuration_variables.name, configuration_variable_values.value")
	@computers = Computer.where("domaine_id = #{@domaine}").order(:hostrequest).all
	@default_computer = User.where(:id => @my_user_id).first.preferences.to_s.split('|')[0].to_s
  end  

  def update
    flash[:ko] = 1
	user_preferences = User.where(:id => @my_user_id).first.preferences.to_s.split('|')
	if user_preferences[0] != params[:computer].to_s
		user_preferences[0] = params[:computer].to_s
		new_user_preferences = user_preferences.join("|")
		User.where(:id => @my_user_id).first.update(:preferences => new_user_preferences)
	end
    variables = ConfigurationVariable.where(:domaine_id => @domaine).all
    variables.each do |variable|
      if params["varvalue#{variable.id}"] != nil
        default_user_config = DefaultUserConfig.where(:domaine => @domaine, :user_id => @my_user_id, :variable_id => variable.id).first
        if default_user_config != nil
          default_user_config.variable_value = params["varvalue#{variable.id}"].to_s
          default_user_config.save
        else
          default_user_config = DefaultUserConfig.new
          default_user_config.domaine_id = @domaine
          default_user_config.user_id = @my_user_id
          default_user_config.variable_id = variable.id
          default_user_config.variable_value = params["varvalue#{variable.id}"].to_s
          default_user_config.save
        end
      end
    end 
    redirect_to controller: 'default_user_configs', action: 'index'
  end
  
end
