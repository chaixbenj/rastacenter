class CreateComputerLastGets < ActiveRecord::Migration[5.1]
  def change
    create_table :computer_last_gets do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :hostrequest, :string, :limit => 50, :null => false
      t.column :object_type, :string, :limit => 50, :null => false
      t.column :version_id, :integer, :limit => 8, :null => true
      t.column :get, :integer, :limit => 1, :null => false, :default => 1
      t.timestamps
    end
    
    add_foreign_key :computer_last_gets, :domaines
    add_foreign_key :computer_last_gets, :versions
    
    add_index :computer_last_gets, [:domaine_id, :hostrequest, :object_type, :version_id], name: "idx_computer_last_gets_1"
    
  end
end
