class CreateLockobjects < ActiveRecord::Migration[5.1]
  def change
    create_table :lockobjects do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :obj_type, :string, :limit => 30, :null => false
      t.column :obj_id, :integer, :limit => 8, :null => false
      t.column :user_id, :integer, :limit => 8, :null => false
      t.timestamps
    end
    
    add_foreign_key :lockobjects, :domaines
    add_foreign_key :lockobjects, :users
    
    add_index :lockobjects, [:domaine_id, :user_id], :name => 'idx_lockobjects_1'
    add_index :lockobjects, [:domaine_id, :obj_type, :obj_id], :name => 'idx_lockobjects_2'
  end
end
