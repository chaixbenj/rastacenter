class CampainTestSuiteForcedConfigsController < ApplicationController
  before_action :require_login

  
  def index
    @step_id = params[:step_id].to_s
    @popup = params[:popup].to_s
    @locked = params[:locked].to_s

	@message, @OK = Commun.set_message(params[:kop])
 
 step = CampainTestSuite.where(:id => @step_id).first
    if step != nil
      @forced_config = step.forced_config
      @step_forced_configs = ConfigurationVariable.select("configuration_variables.id as variable_id, 
configuration_variables.name as variable_name, 
configuration_variable_values.value as allowed_value, 
campain_test_suite_forced_configs.id as campain_test_suite_forced_configs_id, 
campain_test_suite_forced_configs.variable_value as forced_variable_value")
      .joins("INNER JOIN configuration_variable_values on configuration_variable_values.domaine_id=configuration_variables.domaine_id and configuration_variable_values.configuration_variable_id=configuration_variables.id") 
      .joins("LEFT OUTER JOIN campain_test_suite_forced_configs on campain_test_suite_forced_configs.domaine_id=configuration_variable_values.domaine_id and  campain_test_suite_forced_configs.campain_test_suite_id = #{step.id} and campain_test_suite_forced_configs.variable_id = configuration_variables.id")
      .where("configuration_variables.domaine_id = #{@domaine}").all.order("configuration_variables.name, configuration_variable_values.value")
    end
  end  

  def update
    kop = 99
    @step_id = params[:step_id].to_s
    step = CampainTestSuite.where(:id => @step_id).first
    if step != nil
      step.forced_config = 0
      CampainTestSuiteForcedConfig.where(:domaine_id => @domaine, :campain_test_suite_id => step.id).update_all(:updated => 1)
      variables = ConfigurationVariable.where(:domaine_id => @domaine).all
      variables.each do |variable|
        if params["forced#{variable.id}"] != nil and params["forced#{variable.id}"] == "on"
          step_forced_config = CampainTestSuiteForcedConfig.where(:domaine_id => @domaine, :campain_test_suite_id => step.id, :variable_id => variable.id).first
          if step_forced_config != nil
            step_forced_config.updated = 0
            step_forced_config.variable_value = params["varvalue#{variable.id}"].to_s
            step_forced_config.save
          else
            step_forced_config = CampainTestSuiteForcedConfig.new
            step_forced_config.domaine_id = @domaine
            step_forced_config.updated = 0
            step_forced_config.campain_test_suite_id = step.id
            step_forced_config.variable_id = variable.id
            step_forced_config.variable_value = params["varvalue#{variable.id}"].to_s
            step_forced_config.save
          end
          step.forced_config = 1
        end
      end
      CampainTestSuiteForcedConfig.where(:domaine_id => @domaine, :campain_test_suite_id => step.id, :updated => 1).delete_all
      kop = 1
      step.save
    end    
    redirect_to controller: 'campain_test_suite_forced_configs', action: 'index', step_id: @step_id, kop: kop, popup: true
  end
  
end
