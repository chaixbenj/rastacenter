class CreateProjectVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :project_versions do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false 
      t.column :project_id, :integer, :limit => 8, :null => false 
      t.column :version_id, :integer, :limit => 8, :null => false 
      t.column :locked, :integer, :limit => 1, :null => false, :default => 1
      t.column :user_cre, :string, :limit => 50, :null => false
      t.timestamps
    end
    
    add_foreign_key :project_versions, :domaines
    add_foreign_key :project_versions, :projects
    add_foreign_key :project_versions, :versions

  
    add_index :project_versions, [:domaine_id, :project_id, :version_id], name: "idx_project_versions_1"
   end
end
