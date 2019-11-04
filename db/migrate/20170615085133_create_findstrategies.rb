class CreateFindstrategies < ActiveRecord::Migration[5.1]
  def change
    create_table :findstrategies do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 20, :null => false
      t.timestamps
    end
    
    add_foreign_key :findstrategies, :domaines
    
    add_index :findstrategies, :domaine_id, :name => 'idx_findstrategies_1'
    

  end
end
