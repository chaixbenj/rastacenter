class CreateFicheCustoFields < ActiveRecord::Migration[5.1]
  def change
    create_table :fiche_custo_fields do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :fiche_id, :integer, :limit => 8, :null => false
      t.column :ucf_id, :string, :limit => 5, :null => false
      t.column :ucf_name, :string, :limit => 250, :null => false
      t.column :field_id, :integer, :limit => 8, :null => false
      t.column :field_value, :text
      t.timestamps
    end
    
    add_foreign_key :fiche_custo_fields, :domaines
    add_foreign_key :fiche_custo_fields, :fiches, column: :fiche_id, primary_key: :id
    
    add_index :fiche_custo_fields, [:domaine_id, :fiche_id, :ucf_id], name: "idx_fiche_custo_fields_1"
  end
end
