class CreateNodeForcedComputers < ActiveRecord::Migration[5.1]
  def change
    create_table :node_forced_computers do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :node_id, :integer, :limit => 8, :null => false
      t.column :hostrequest, :string, :limit => 50, :null => false
      t.timestamps
    end
    
    add_foreign_key :node_forced_computers, :domaines
    add_foreign_key :node_forced_computers, :nodes
    
    add_index :node_forced_computers, [:domaine_id, :node_id], name: "idx_node_forced_computers_1"
  end
end
