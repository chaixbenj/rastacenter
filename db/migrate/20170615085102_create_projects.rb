#done
class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false 
      t.column :name, :string, :limit => 250, :null => false 
      t.column :description, :text
      t.column :user_cre, :string, :limit => 50, :null => false 
      t.column :user_maj, :string, :limit => 50, :null => true 
      t.timestamps
    end
    add_foreign_key :projects, :domaines
    add_index :projects, [:domaine_id, :name], name: "idx_projects_1"
  end
end
