class CreateUserprojects < ActiveRecord::Migration[5.1]
  def change
    create_table :userprojects do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false 
      t.column :user_id, :integer,  :limit => 8, :null => false   
      t.column :project_id, :integer,  :limit => 8, :null => false   
      t.column :role_id, :integer,  :limit => 8, :null => false   
      t.timestamps
    end
    
    add_foreign_key :userprojects, :domaines
    add_foreign_key :userprojects, :projects
    add_foreign_key :userprojects, :users
    add_foreign_key :userprojects, :roles
    
    add_index :userprojects, [:domaine_id, :user_id, :project_id], name: "idx_userprojects_1"
    add_index :userprojects, [:domaine_id, :project_id, :user_id], name: "idx_userprojects_2"
  end
end
