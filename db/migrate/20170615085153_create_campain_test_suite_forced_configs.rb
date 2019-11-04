class CreateCampainTestSuiteForcedConfigs < ActiveRecord::Migration[5.1]
  def change
    create_table :campain_test_suite_forced_configs do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :campain_test_suite_id, :integer, :limit => 8, :null => false
      t.column :variable_id, :integer, :limit => 8, :null => false
      t.column :variable_value, :string, :limit => 150, :null => true
      t.column :updated, :integer, :limit => 1, :null => false, :default => 0
      t.timestamps
    end
    
    add_foreign_key :campain_test_suite_forced_configs, :domaines
    add_foreign_key :campain_test_suite_forced_configs, :campain_test_suites
    add_foreign_key :campain_test_suite_forced_configs, :configuration_variables, column: :variable_id, primary_key: :id

    
    add_index :campain_test_suite_forced_configs, [:domaine_id, :campain_test_suite_id, :variable_id], unique: true, name: "idx_campain_test_suites_forced_config_1"
  end
end
