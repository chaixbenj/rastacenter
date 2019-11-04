class CreateConfigurationVariables < ActiveRecord::Migration[5.1]
  def change
    create_table :configuration_variables do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 50, :null => false
      t.column :description, :text
      t.column :is_deletable, :integer, :limit => 1, :null => false, :default => 1
      t.column :no_value, :integer, :limit => 1, :null => false, :default => 0
      t.column :is_numeric, :integer, :limit => 1, :null => true
      t.column :is_boolean, :integer, :limit => 1, :null => true
      t.timestamps
    end
    
    add_foreign_key :configuration_variables, :domaines
    
    add_index :configuration_variables, [:domaine_id, :name], :name => 'idx_configuration_variables_1'
    
  
  end
end
