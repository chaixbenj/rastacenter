class CreateRunEndedNodes < ActiveRecord::Migration[5.1]
  def change
    create_table :run_ended_nodes do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :run_id, :integer, :limit => 8, :null => false
      t.column :test_node_id_externe, :integer, :limit => 8, :null => true
      t.timestamps
    end
    add_foreign_key :run_ended_nodes, :domaines
    add_foreign_key :run_ended_nodes, :runs
    add_index :run_ended_nodes, [:domaine_id, :run_id, :test_node_id_externe], :name => 'idx_run_ended_nodes_1'
  end
end
