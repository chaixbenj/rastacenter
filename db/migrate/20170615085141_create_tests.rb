class CreateTests < ActiveRecord::Migration[5.1]
  def change
    create_table :tests do |t|
		t.column :domaine_id, :integer, :limit => 8, :null => false
		t.column :test_folder_id, :integer, :limit => 8, :null => false
		t.column :version_id, :integer, :limit => 8, :null => true
		t.column :sheet_id, :integer, :limit => 8, :null => true
		t.column :test_state_id, :integer, :limit => 8, :null => true
		t.column :test_level_id, :integer, :limit => 8, :null => true
		t.column :test_type_id, :integer, :limit => 8, :null => true
		t.column :name, :string, :limit => 250, :null => false
		t.column :description, :text
		t.column :private, :integer, :limit => 1, :null => false, :default => 1
		t.column :owner_user_id, :integer, :limit => 8, :null => false
		t.column :user_maj, :string, :limit => 50, :null => true
		t.column :current_id, :integer, :limit => 8
		t.column :lastresult, :string, :limit => 50, :null => true
		t.column :has_real_step, :integer, :limit => 1, :null => true
		t.column :parameters, :string, :limit => 255, :null => true
		t.column :is_atdd, :integer, :limit => 1, :null => true
		t.column :is_valid, :integer, :limit => 1, :null => true
		t.column :fiche_id, :integer, :limit => 8, :null => true
		t.timestamps
    end
    
    add_foreign_key :tests, :domaines
    add_foreign_key :tests, :test_folders
    add_foreign_key :tests, :versions
    add_foreign_key :tests, :sheets
    add_foreign_key :tests, :liste_values, column: :test_state_id, primary_key: :id
    add_foreign_key :tests, :liste_values, column: :test_level_id, primary_key: :id
    add_foreign_key :tests, :liste_values, column: :test_type_id, primary_key: :id
    
    add_index :tests, [:domaine_id, :version_id, :owner_user_id, :private, :name, :test_type_id, :test_state_id, :test_level_id], :name => 'idx_tests_1'
    add_index :tests, [:domaine_id, :test_folder_id, :version_id, :owner_user_id, :private, :test_type_id], :name => 'idx_tests_2'
	add_index :tests, [:domaine_id, :is_atdd, :description], length: {description: 255}, :name => 'idx_tests_atdd_2'
	add_index :tests, [:domaine_id, :is_atdd], :name => 'idx_tests_atdd'
  end
end
