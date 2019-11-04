class CreateFicheDownloads < ActiveRecord::Migration[5.1]
  def change
    create_table :fiche_downloads do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :fiche_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 255, :null => false
      t.column :guid, :string, :limit => 40, :null => false
      t.timestamps
    end
    add_foreign_key :fiche_downloads, :domaines
    add_foreign_key :fiche_downloads, :fiches, column: :fiche_id, primary_key: :id
    
    add_index :fiche_downloads, [:domaine_id, :fiche_id, :name], name: "idx_fiche_downloads_1"
  end
end
