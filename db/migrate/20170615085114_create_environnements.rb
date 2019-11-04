class CreateEnvironnements < ActiveRecord::Migration[5.1]
  def change
    create_table :environnements do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :version_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 60, :null => false
      t.column :description, :text
	  t.column :current_id, :integer, :limit => 8
      t.timestamps
    end
    
    add_foreign_key :environnements, :domaines
    add_foreign_key :environnements, :versions
    
    add_index :environnements, [:domaine_id, :version_id, :name], :name => 'idx_environnements_1'

  end
end
