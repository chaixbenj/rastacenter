class CreateComputers < ActiveRecord::Migration[5.1]
  def change
    create_table :computers do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :hostrequest, :string, :limit => 50, :null => false
      t.column :guid, :string, :limit => 40, :null => false
      t.column :last_connexion , :datetime
      t.timestamps
    end
    
    add_foreign_key :computers, :domaines
    
    add_index :computers, [:domaine_id, :hostrequest],  unique: true, name: "idx_computers_1"
    add_index :computers, [:domaine_id, :hostrequest, :guid], name: "idx_computers_2"
    add_index :computers, [:guid],  unique: true, name: "idx_computers_3"
  end
end
