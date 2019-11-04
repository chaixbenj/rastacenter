class CreateConfigurationVariableValues < ActiveRecord::Migration[5.1]
  def change
    create_table :configuration_variable_values do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :configuration_variable_id, :integer, :limit => 8, :null => false
      t.column :value, :string, :limit => 150, :null => false
      t.column :is_modifiable, :integer, :limit => 1, :null => false, :default => 1
      t.timestamps
    end
    
    add_foreign_key :configuration_variable_values, :domaines
    add_foreign_key :configuration_variable_values, :configuration_variables
    
    add_index :configuration_variable_values, [:domaine_id, :configuration_variable_id], :name => 'idx_configuration_variable_values_1'
    
    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 2,
                              value: "FFOX",
                              is_modifiable: 0

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 2,
                              value: "CHRO",
                              is_modifiable: 0

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 2,
                              value: "EDGE",
                              is_modifiable: 0
    
    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 2,
                              value: "IE",
                              is_modifiable: 0

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 2,
                              value: "SAFA",
                              is_modifiable: 0


    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 3,
                              value: "fullsize",
                              is_modifiable: 0

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 3,
                              value: "1440x900",
                              is_modifiable: 0
    

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 4,
                              value: "WIN",
                              is_modifiable: 0

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 4,
                              value: "MAC",
                              is_modifiable: 0    


    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 5,
                              value: "PC",
                              is_modifiable: 0    

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 5,
                              value: "MAC",
                              is_modifiable: 0    

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 5,
                              value: "Mobile Android",
                              is_modifiable: 0    

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 5,
                              value: "Mobile iOS",
                              is_modifiable: 0    


    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 6,
                              value: "true",
                              is_modifiable: 0    

    ConfigurationVariableValue.create  domaine_id: 1,
                              configuration_variable_id: 6,
                              value: "false",
                              is_modifiable: 0        
  end
end
