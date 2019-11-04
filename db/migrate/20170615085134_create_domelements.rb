class CreateDomelements < ActiveRecord::Migration[5.1]
  def change
    create_table :domelements do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :funcandscreen_id, :integer, :limit => 8, :null => false
      t.column :version_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 50, :null => false
      t.column :description, :text
      t.column :strategie, :string, :limit => 20, :null => false
      t.column :path, :string, :limit => 500, :null => false
      t.column :is_used, :integer, :limit => 2, :null => false, :default => 0
	  t.column :current_id, :integer, :limit => 8
      t.timestamps
    end
    add_foreign_key :domelements, :domaines
    add_foreign_key :domelements, :funcandscreens
    add_foreign_key :domelements, :versions
    
    add_index :domelements, [:domaine_id, :funcandscreen_id, :version_id], :name => 'idx_domelements_1'
  end
end
