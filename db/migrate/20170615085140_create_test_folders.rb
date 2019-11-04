class CreateTestFolders < ActiveRecord::Migration[5.1]
  def change
    create_table :test_folders do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :project_id, :integer, :limit => 8, :null => true
      t.column :test_folder_father_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 250, :null => false
      t.column :can_be_updated, :integer, :limit => 1, :null => false, :default => 1
	  t.column :is_atdd, :integer, :limit => 1, :null => true
      t.timestamps
    end
    
    add_foreign_key :test_folders, :domaines
    add_foreign_key :test_folders, :projects
    add_foreign_key :test_folders, :test_folders, column: :test_folder_father_id, primary_key: :id
	    
    add_index :test_folders, [:domaine_id, :test_folder_father_id, :project_id], :name => 'idx_test_folders_1'
   add_index :test_folders, [:domaine_id, :is_atdd], :name => 'idx_test_folders_atdd'
  end
end
