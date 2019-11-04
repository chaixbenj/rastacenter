class CreateNodeForcedConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :node_forced_configs do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :node_id, :integer, :limit => 8, :null => false
      t.column :variable_id, :integer, :limit => 8, :null => false
      t.column :variable_value, :string, :limit => 150, :null => true
      t.column :updated, :integer, :limit => 1, :null => false, :default => 0
      t.timestamps
    end
    
    add_foreign_key :node_forced_configs, :domaines
    add_foreign_key :node_forced_configs, :nodes
    add_foreign_key :node_forced_configs, :configuration_variables, column: :variable_id, primary_key: :id
    
    add_index :node_forced_configs, [:domaine_id, :node_id, :variable_id, :updated], :name => 'idx_node_forced_configs_1'
  end
end
