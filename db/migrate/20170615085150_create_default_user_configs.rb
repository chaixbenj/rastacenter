class CreateDefaultUserConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :default_user_configs do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :user_id, :integer, :limit => 8, :null => false
      t.column :variable_id, :integer, :limit => 8, :null => false
      t.column :variable_value, :string, :limit => 150, :null => false
      t.timestamps
    end
    
    add_foreign_key :default_user_configs, :domaines
    add_foreign_key :default_user_configs, :users
    add_foreign_key :default_user_configs, :configuration_variables, column: :variable_id, primary_key: :id
    
    add_index :default_user_configs, [:domaine_id, :user_id, :variable_id], :name => 'idx_default_user_configs_1'
  end
end
