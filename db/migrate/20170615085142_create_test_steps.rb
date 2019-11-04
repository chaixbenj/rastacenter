class CreateTestSteps < ActiveRecord::Migration[5.1]
  def change
    create_table :test_steps do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :test_id, :integer, :limit => 8, :null => false
      t.column :sequence, :integer, :limit => 2, :null => false
      t.column :sheet_id, :integer, :limit => 8, :null => true
      t.column :funcandscreen_id, :integer, :limit => 8, :null => true
      t.column :ext_node_id, :integer, :limit => 8, :null => true
      t.column :procedure_id, :integer, :limit => 8, :null => true
      t.column :parameters, :text, :null => true
      t.column :user_maj, :string, :limit => 50, :null => true
	  t.column :atdd_test_id, :integer, :limit => 8, :null => true
	  t.column :code, :text, :null => true
      t.column :type_code, :string, :limit => 10, :null => true
	  t.column :temporary, :integer, :limit => 1, :null => true
	  t.column :hold, :integer, :limit => 1, :null => true
      t.timestamps
    end
    
    add_foreign_key :test_steps, :domaines
    add_foreign_key :test_steps, :tests
    add_foreign_key :test_steps, :sheets
    add_foreign_key :test_steps, :funcandscreens
    add_foreign_key :test_steps, :procedures
	add_foreign_key :test_steps, :tests, column: :atdd_test_id, primary_key: :id
    
    add_index :test_steps, [:domaine_id, :test_id, :sequence, :procedure_id], :name => 'idx_test_steps_1'
  end
end
