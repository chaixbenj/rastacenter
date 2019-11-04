class CreateRunConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :run_configs do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :run_id, :integer, :limit => 8, :null => false
      t.column :variable_id, :integer, :limit => 8, :null => false
      t.column :variable_value, :string, :limit => 150, :null => true
      t.timestamps
    end
    
    add_foreign_key :run_configs, :domaines
    add_foreign_key :run_configs, :runs
    add_foreign_key :run_configs, :configuration_variables, column: :variable_id, primary_key: :id
    
    add_index :run_configs, [:domaine_id, :run_id, :variable_id], unique: true, :name => 'idx_run_configs_1'
  end
end
