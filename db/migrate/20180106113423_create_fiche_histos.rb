class CreateFicheHistos < ActiveRecord::Migration[5.1]
  def change
    create_table :fiche_histos do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :fiche_id, :integer, :limit => 8, :null => false
      t.column :status, :string, :limit => 50, :null => false
      t.column :comment, :text
      t.column :jsondesc, :text
      t.column :user_cre, :string, :limit => 50, :null => false
      t.timestamps
    end
    
    add_foreign_key :fiche_histos, :domaines
    add_foreign_key :fiche_histos, :fiches, column: :fiche_id, primary_key: :id
    
    add_index :fiche_histos, [:domaine_id, :fiche_id, :status], name: "idx_fiche_histos_1"
  end
end
