class CreateListes < ActiveRecord::Migration[5.1]
  def change
    create_table :listes do |t|
       t.column :domaine_id, :integer, :limit => 8, :null => false
       t.column :code, :string, :limit => 50, :null => true
       t.column :name, :string, :limit => 250, :null => false
       t.column :description, :text
       t.column :is_deletable, :integer, :limit => 1, :default => 1, :null => false
      t.timestamps
    end
    
    add_foreign_key :listes, :domaines
    
    add_index :listes, [:domaine_id, :code], :name => 'idx_listes_1'
    
      
  end
end
