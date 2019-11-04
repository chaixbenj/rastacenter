class CreateFiches < ActiveRecord::Migration[5.1]
  def change
    create_table :fiches do |t|
		t.column :domaine_id, :integer, :limit => 8, :null => false
		t.column :type_fiche_id, :integer, :limit => 8, :null => false
		t.column :name, :string, :limit => 250, :null => false
		t.column :status, :string, :limit => 50, :null => false
		t.column :description, :text
		t.column :user_cre, :string, :limit => 50, :null => false 
		t.column :user_maj, :string, :limit => 50, :null => true 
		t.column :lastresult, :string, :limit => 50, :null => true
		t.column :status_id, :integer, :limit => 8, :null => true
		t.column :user_assign_id, :integer, :limit => 8, :null => true
		t.column :user_assign_name, :string, :limit => 50, :null => true
		t.column :priority_id, :integer, :limit => 8, :null => true
		t.column :priority_name, :string, :limit => 50, :null => true
		t.column :cycle_id, :integer, :limit => 8, :null => true
		t.column :project_id, :integer, :limit => 8, :null => true
		t.column :test_id, :integer, :limit => 8, :null => true
		t.column :proc_id, :integer, :limit => 8, :null => true
		t.column :action_id, :integer, :limit => 8, :null => true
		t.column :father_id, :integer, :limit => 8, :null => true
		t.column :lignee_id, :integer, :limit => 8, :null => true
		t.timestamps
    end
    
    add_foreign_key :fiches, :domaines
    add_foreign_key :fiches, :type_fiches, column: :type_fiche_id, primary_key: :id
	add_foreign_key :fiches, :projects
	add_foreign_key :fiches, :cycles
	add_foreign_key :fiches, :users, column: :user_assign_id, primary_key: :id
	add_foreign_key :fiches, :liste_values, column: :status_id, primary_key: :id
	add_foreign_key :fiches, :liste_values, column: :priority_id, primary_key: :id
	add_foreign_key :tests, :fiches, column: :fiche_id, primary_key: :id
    
    add_index :fiches, [:domaine_id, :type_fiche_id, :status], name: "idx_fiches_1"
	add_index :fiches, [:domaine_id, :project_id, :type_fiche_id, :status_id], name: "idx_fiches_2"
    add_index :fiches, [:domaine_id, :project_id, :test_id, :proc_id, :action_id], name: "idx_fiches_3"  
	add_index :fiches, [:domaine_id, :lignee_id], name: "idx_fiches_4"
  end
end
