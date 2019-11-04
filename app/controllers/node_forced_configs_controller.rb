class NodeForcedConfigsController < ApplicationController
  before_action :require_login

  
  def index
    @ext_node_id = params[:ext_node_id].to_s
    @sheet_id = params[:sheet_id].to_s
    @popup = params[:popup].to_s

    @message, @OK = Commun.set_message(params[:kop])
	
    node = Node.where(:sheet_id => @sheet_id, :id_externe => @ext_node_id).first
    @forced_config = node.forced
    owner = 0
    private = 1
    if node !=nil
      sheet = Sheet.where(:id => node.sheet_id).first
      if sheet != nil
        owner = sheet.owner_user_id
        private = sheet.private
        @version_id = sheet.version_id
      end
    end
    if (@can_manage_public_test_suite == 1 and private ==0) or owner == @my_user_id
      @can_manage = 1
    else
      @can_manage = 0
    end
    @computers = Computer.where("domaine_id = #{@domaine}").order(:hostrequest).all
    @node_forced_computer = NodeForcedComputer.where("domaine_id = #{@domaine} and node_id = #{node.id} ").first
    @node_forced_configs = ConfigurationVariable.select("configuration_variables.id as variable_id, configuration_variables.name as variable_name, configuration_variable_values.value as allowed_value, node_forced_configs.id as node_forced_configs_id, node_forced_configs.variable_value as forced_variable_value")
    .joins("INNER JOIN configuration_variable_values on configuration_variable_values.domaine_id=configuration_variables.domaine_id and configuration_variable_values.configuration_variable_id=configuration_variables.id")
	.joins("LEFT OUTER JOIN node_forced_configs on node_forced_configs.domaine_id = configuration_variables.domaine_id and node_forced_configs.node_id = #{node.id} and node_forced_configs.variable_id = configuration_variables.id")
    .where("configuration_variables.domaine_id = #{@domaine}").all.order("configuration_variables.name, configuration_variable_values.value")
  end  

  def update
    kop = 99
    @ext_node_id = params[:ext_node_id].to_s
    @sheet_id = params[:sheet_id].to_s  
    node = Node.where(:sheet_id => @sheet_id, :id_externe => @ext_node_id).first
    node.force_type = nil
    node.forced = 0
    if node != nil
      if params["forcedcomputer"] != nil
        node_forced_computer = NodeForcedComputer.where("domaine_id = #{@domaine} and node_id = #{node.id} ").first 
        if node_forced_computer == nil
          node_forced_computer = NodeForcedComputer.new
          node_forced_computer.domaine_id = @domaine
          node_forced_computer.node_id = node.id
        end
        node_forced_computer.hostrequest = params["valueforcedcomputer"]
        node_forced_computer.save
        node.force_type = "forced_config"
        node.forced = 1
		node.new_thread = 1
      else
        NodeForcedComputer.where("domaine_id = #{@domaine} and node_id = #{node.id} ").delete_all
      end
      
      NodeForcedConfig.where(:domaine_id => @domaine, :node_id => node.id).update_all(:updated => 1)
      variables = ConfigurationVariable.where(:domaine_id => @domaine).all
      variables.each do |variable|
        if params["forced#{variable.id}"] != nil and params["forced#{variable.id}"] == "on"
          node_forced_config = NodeForcedConfig.where(:domaine_id => @domaine, :node_id => node.id, :variable_id => variable.id).first
          if node_forced_config != nil
            node_forced_config.updated = 0
            node_forced_config.variable_value = params["varvalue#{variable.id}"].to_s
            node_forced_config.save
          else
            node_forced_config = NodeForcedConfig.new
            node_forced_config.domaine_id = @domaine
            node_forced_config.updated = 0
            node_forced_config.node_id = node.id
            node_forced_config.variable_id = variable.id
            node_forced_config.variable_value = params["varvalue#{variable.id}"].to_s
            node_forced_config.save
          end
          node.force_type = "forced_config"
          node.forced = 1
		  node.new_thread = 1
        end
      end
      NodeForcedConfig.where(:domaine_id => @domaine, :node_id => node.id, :updated => 1).delete_all
      kop = 1
      node.save
    end    
    redirect_to controller: 'node_forced_configs', action: 'index', ext_node_id: @ext_node_id, sheet_id: @sheet_id, kop: kop, popup: true
  end
  
end
