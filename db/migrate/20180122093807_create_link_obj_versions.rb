class CreateLinkObjVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :link_obj_versions do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :obj_type, :string, :limit => 20, :null => false
      t.column :obj_id, :integer,  :limit => 8, :null => false
      t.column :obj_current_id, :integer,  :limit => 8, :null => false
      t.column :version_id, :integer,  :limit => 8, :null => true
      t.timestamps
    end
    
    add_foreign_key :link_obj_versions, :domaines
    add_foreign_key :link_obj_versions, :versions
    
    add_index :link_obj_versions, [:domaine_id , :version_id, :obj_type, :obj_id], unique: true, name: "idx_link_obj_versions_1"
    
  end
end
