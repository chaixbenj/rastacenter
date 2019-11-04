class CreateRuns < ActiveRecord::Migration[5.1]
  def change
    create_table :runs do |t|
		t.column :domaine_id, :integer, :limit => 8, :null => false
		t.column :campain_id, :integer, :limit => 8, :null => true
		t.column :user_id, :integer, :limit => 8, :null => false
		t.column :run_type, :string, :limit => 40, :null => false
		t.column :test_id, :integer, :limit => 8, :null => true
		t.column :suite_id, :integer, :limit => 8, :null => true
		t.column :hostrequest, :string, :limit => 50, :null => false
		t.column :status, :string, :limit => 15, :null => true
		t.column :version_id, :integer, :limit => 8, :null => true
		t.column :run_father_id, :integer, :limit => 8, :null => true
		t.column :start_node_id, :integer, :limit => 8, :null => true
		t.column :campain_test_suite_id, :integer, :limit => 8, :null => true
		t.column :unlock_run_id, :integer, :limit => 8, :null => true
		t.column :project_id, :integer, :limit => 8, :null => true
		t.column :name, :string, :limit => 500, :null => true
		t.column :private, :integer, :limit => 1, :null => true
		t.column :nbtest, :integer, :limit => 4, :null => false, :default => 0
		t.column :nbtestpass, :integer, :limit => 4, :null => false, :default => 0
		t.column :nbtestfail, :integer, :limit => 4, :null => false, :default => 0
		t.column :nbprocfail, :integer, :limit => 4, :null => false, :default => 0
		t.column :conf_string, :text, :null => true
		t.column :exec_code, :text, :null => true
		t.column :nb_screenshots_diffs, :integer, :limit => 4, :null => true
		t.timestamps
    end
    
    add_foreign_key :runs, :domaines
    add_foreign_key :runs, :runs, column: :run_father_id, primary_key: :id
    
    
    
    add_index :runs, [:domaine_id, :user_id], :name => 'idx_runs_1'
    add_index :runs, [:domaine_id, :hostrequest, :status, :campain_id], :name => 'idx_runs_2'
    add_index :runs, [:domaine_id, :unlock_run_id], :name => 'idx_runs_3'
  end
end
