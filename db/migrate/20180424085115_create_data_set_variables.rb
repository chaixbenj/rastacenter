class CreateDataSetVariables < ActiveRecord::Migration[5.1]
  def change
    create_table :data_set_variables do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :init_variable_id, :integer, :limit => 8, :null => true
	  t.column :project_id, :integer, :limit => 8, :null => false
      t.column :data_set_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 50, :null => false
      t.column :description, :text
      t.column :value, :string, :limit => 255, :null => true
	  t.column :is_numeric, :integer, :limit => 1, :null => true
	  t.column :is_boolean, :integer, :limit => 1, :null => true
      t.column :is_used, :integer, :limit => 1, :null => false, :default => 0
      t.timestamps
    end
    
    add_foreign_key :data_set_variables, :domaines
    add_foreign_key :data_set_variables, :projects
    add_foreign_key :data_set_variables, :data_sets
    add_foreign_key :data_set_variables, :data_set_variables, column: :init_variable_id, primary_key: :id
    
    add_index :data_set_variables, [:domaine_id, :data_set_id, :init_variable_id], :name => 'idx_data_set_variables_1'
    add_index :data_set_variables, [:domaine_id, :project_id, :data_set_id], :name => 'idx_data_set_variables_2'
  end
end
