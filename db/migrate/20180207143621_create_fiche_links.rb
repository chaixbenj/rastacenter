class CreateFicheLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :fiche_links do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :fiche_id, :integer, :limit => 8, :null => false
      t.column :fiche_linked_id, :integer, :limit => 8, :null => false
      t.timestamps
    end
    
    add_foreign_key :fiche_links, :domaines
    add_foreign_key :fiche_links, :fiches, column: :fiche_id, primary_key: :id
    
    add_index :fiche_links, [:domaine_id, :fiche_id], name: "idx_fiche_links_1"
  end
end
