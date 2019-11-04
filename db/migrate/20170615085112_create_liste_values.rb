class CreateListeValues < ActiveRecord::Migration[5.1]
  def change
    create_table :liste_values do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :liste_id, :integer, :limit => 8, :null => false
      t.column :value, :string, :limit => 100, :null => true
      t.column :is_modifiable, :integer, :limit => 1, :default => 1, :null => false
      t.timestamps
    end

    add_foreign_key :liste_values, :domaines
    add_foreign_key :liste_values, :listes
    
    add_index :liste_values, [:domaine_id, :liste_id], :name => 'idx_liste_values_1'
    

  end
end
