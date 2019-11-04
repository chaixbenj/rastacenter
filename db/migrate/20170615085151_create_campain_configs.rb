class CreateCampainConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :campain_configs do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :campain_id, :integer, :limit => 8, :null => false
      t.column :variable_id, :integer, :limit => 8, :null => false
      t.column :variable_value, :string, :limit => 150, :null => false
      t.timestamps
    end
    
    add_foreign_key :campain_configs, :domaines
    add_foreign_key :campain_configs, :campains
    add_foreign_key :campain_configs, :configuration_variables, column: :variable_id, primary_key: :id

    
    add_index :campain_configs, [:domaine_id, :campain_id, :variable_id], :name => 'idx_campain_configs_1'
  end
end
