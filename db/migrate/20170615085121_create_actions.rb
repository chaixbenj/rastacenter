class CreateActions < ActiveRecord::Migration[5.1]
  def change
    create_table :actions do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 60, :null => false
      t.column :description, :text
      t.column :parameters, :string, :limit => 1024, :null => true
      t.column :code, :text
      t.column :callable_in_proc, :integer,  :limit => 1, :null => false, :default => 1
      t.column :version_id, :integer,  :limit => 8, :null => true
      t.column :action_admin_id, :integer, :limit => 8, :null => true
      t.column :is_modifiable, :integer,:limit => 1, :null => false, :default => 1
      t.column :nb_used, :integer, :limit => 2, :null => false, :default => 0
	  t.column :current_id, :integer, :limit => 8
      t.timestamps
    end
    
    add_foreign_key :actions, :domaines
    add_foreign_key :actions, :versions
    add_foreign_key :actions, :users, column: :action_admin_id, primary_key: :id
    
    add_index :actions, [:domaine_id , :version_id, :callable_in_proc], name: "idx_actions_1"
    add_index :actions, [:domaine_id , :version_id , :name ], name: "idx_actions_2"
    add_index :actions, [:domaine_id , :version_id , :is_modifiable, :callable_in_proc, :name], name: "idx_actions_3"
    

  end
end
