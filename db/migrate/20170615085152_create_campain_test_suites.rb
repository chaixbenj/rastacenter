class CreateCampainTestSuites < ActiveRecord::Migration[5.1]
  def change
    create_table :campain_test_suites do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :campain_id, :integer, :limit => 8, :null => false
      t.column :sheet_id, :integer, :limit => 8, :null => false
      t.column :sequence, :integer, :limit => 2, :null => false
      t.column :forced_config, :integer, :limit => 1, :null => false, :default => 0
      t.timestamps
    end
    
    add_foreign_key :campain_test_suites, :domaines
    add_foreign_key :campain_test_suites, :campains
    add_foreign_key :campain_test_suites, :sheets

    add_index :campain_test_suites, [:domaine_id, :campain_id, :sequence], :name => 'idx_campain_test_suites_1'
  end
end
