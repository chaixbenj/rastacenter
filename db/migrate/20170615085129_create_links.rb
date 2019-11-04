class CreateLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :links do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :sheet_id, :integer, :limit => 8, :null => false
      t.column :id_externe, :string, :limit => 50, :null => false
      t.column :node_father_id_fk, :integer, :limit => 8, :null => false
      t.column :node_son_id_fk, :integer, :limit => 8, :null => false
      t.column :inflexion_x, :integer, :limit => 2, :null => true
      t.column :inflexion_y, :integer, :limit => 2, :null => true
      t.column :curved, :integer, :limit => 1, :null => false, :default => 0
	  t.column :wait_link, :integer, :limit => 1, :null => true
      t.timestamps
    end
    
    add_foreign_key :links, :domaines
    add_foreign_key :links, :sheets
    
    add_index :links, [:domaine_id, :sheet_id, :id_externe], name: "idx_links_1"
    add_index :links, [:domaine_id, :sheet_id, :node_father_id_fk], name: "idx_links_2"
    add_index :links, [:domaine_id, :sheet_id, :node_son_id_fk], name: "idx_links_3"
  end
end
