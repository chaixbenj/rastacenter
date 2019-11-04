class CreateRunStepResults < ActiveRecord::Migration[5.1]
  def change
    create_table :run_step_results do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :run_id, :integer, :limit => 8, :null => false
      t.column :suite_id, :integer, :limit => 8, :null => true
      t.column :suite_sequence, :integer, :limit => 2, :null => true
      t.column :test_id, :integer, :limit => 8, :null => true
      t.column :test_node_id_externe, :integer, :limit => 8, :null => true
      t.column :proc_id, :integer, :limit => 8, :null => true
      t.column :proc_sequence, :integer, :limit => 2, :null => true
      t.column :action_id, :integer, :limit => 8, :null => true
      t.column :suite_name, :string, :limit => 250, :null => true
      t.column :test_name, :string, :limit => 250, :null => true
      t.column :proc_name, :string, :limit => 250, :null => true
      t.column :action_name, :string, :limit => 60, :null => true
      t.column :params, :string, :limit => 1024, :null => true
      t.column :steplevel, :string, :limit => 20, :null => true
      t.column :detail, :text
      t.column :expected, :text
      t.column :result_detail, :text
      t.column :result, :string, :limit => 50, :null => true
      t.column :initial_result, :string, :limit => 50, :null => true
      t.column :comment, :text
      t.column :histo, :text
	  t.column :atdd_test_id, :integer, :limit => 8, :null => true
	  t.column :atdd_sequence, :integer, :limit => 2, :null => true
      t.timestamps
    end
    
    add_foreign_key :run_step_results, :domaines
    add_foreign_key :run_step_results, :runs
    
    add_index :run_step_results, [:domaine_id, :run_id, :suite_id, :suite_sequence, :test_id, :test_node_id_externe, :proc_id, :proc_sequence, :steplevel, :result, :action_id], :name => 'idx_run_step_results_1'
  end
end
