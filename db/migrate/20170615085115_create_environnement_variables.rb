class CreateEnvironnementVariables < ActiveRecord::Migration[5.1]
  def change
    create_table :environnement_variables do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :init_variable_id, :integer, :limit => 8, :null => true
	  t.column :project_id, :integer, :limit => 8, :null => false
      t.column :environnement_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 50, :null => false
      t.column :description, :text
      t.column :value, :string, :limit => 255, :null => true
      t.column :is_used, :integer, :limit => 1, :null => false, :default => 0
      t.column :is_numeric, :integer, :limit => 1, :null => true
      t.column :is_boolean, :integer, :limit => 1, :null => true	  
      t.timestamps
    end
    
    add_foreign_key :environnement_variables, :domaines
    add_foreign_key :environnement_variables, :projects
    add_foreign_key :environnement_variables, :environnements
    add_foreign_key :environnement_variables, :environnement_variables, column: :init_variable_id, primary_key: :id
    
    add_index :environnement_variables, [:domaine_id, :environnement_id, :init_variable_id], :name => 'idx_environnement_variables_1'
    add_index :environnement_variables, [:domaine_id, :project_id, :environnement_id], :name => 'idx_environnement_variables_2'
  end
end
