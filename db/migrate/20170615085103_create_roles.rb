class CreateRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :roles do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 50, :null => false
      t.column :droits, :string, :limit => 50, :null => false
      t.timestamps
    end

  add_foreign_key :roles, :domaines  
	add_index :roles, :domaine_id, name: "idx_roles_1"
	

  end
  
         
end
