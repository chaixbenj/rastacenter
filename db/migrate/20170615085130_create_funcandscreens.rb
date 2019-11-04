class CreateFuncandscreens < ActiveRecord::Migration[5.1]
  def change
    create_table :funcandscreens do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :project_id, :integer , :limit => 8, :null => false
      t.column :name, :string, :limit => 250, :null => true
      t.timestamps
    end
    
    add_foreign_key :funcandscreens, :domaines
    add_foreign_key :funcandscreens, :projects
    
    add_index :funcandscreens, [:domaine_id, :project_id], :name => 'idx_funcandscreens_1'
  end
end
