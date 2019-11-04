class CreateRunSuiteSchemes < ActiveRecord::Migration[5.1]
  def change
    create_table :run_suite_schemes do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :run_id, :integer, :limit => 8, :null => false
      t.column :suite_id, :integer, :limit => 8, :null => false
      t.column :sequence, :integer, :limit => 2, :null => true
      t.column :jsonnode, :text
      t.column :jsonlink, :text
      t.timestamps
    end
    
    add_foreign_key :run_suite_schemes, :domaines
    add_foreign_key :run_suite_schemes, :runs
    add_foreign_key :run_suite_schemes, :sheets, column: :suite_id, primary_key: :id
    
    add_index :run_suite_schemes, [:domaine_id, :run_id, :suite_id, :sequence], unique: true, name: "idx_run_suite_schemes_1"

  end
  
end
