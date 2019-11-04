class CreateNodes < ActiveRecord::Migration[5.1]
  def change
    create_table :nodes do |t|
		t.column :domaine_id, :integer, :limit => 8, :null => false 
		t.column :sheet_id, :integer, :limit => 8, :null => false
		t.column :id_externe, :integer, :limit => 8, :null => false
		t.column :x, :integer, :limit => 2, :null => false
		t.column :y, :integer, :limit => 2, :null => false
		t.column :name, :string, :limit => 250, :null => false
		t.column :type_node, :string, :limit => 20, :null => false
		t.column :obj_type, :string, :limit => 20, :null => false
		t.column :obj_id, :integer, :limit => 8, :null => true
		t.column :forced, :integer, :default => 0, :limit => 1, :null => false
		t.column :force_type, :string, :limit => 20, :null => true
		t.column :user_cre, :string, :limit => 50, :null => true
		t.column :user_maj, :string, :limit => 50, :null => true
		t.column :new_thread, :integer, :limit => 1, :null => true
		t.column :thread_number, :integer, :limit => 1, :null => true
		t.column :hold, :integer, :limit => 1, :null => true
		t.timestamps
    end
    add_foreign_key :nodes, :domaines
    add_foreign_key :nodes, :sheets
    
    add_index :nodes, [:domaine_id, :sheet_id], :name => 'idx_nodes_1'
    add_index :nodes, [:domaine_id, :sheet_id, :obj_id], :name => 'idx_nodes_2'
    add_index :nodes, [:domaine_id, :sheet_id, :obj_type], :name => 'idx_nodes_3'
    add_index :nodes, [:domaine_id, :obj_id, :obj_type], :name => 'idx_nodes_4'
  end
end
