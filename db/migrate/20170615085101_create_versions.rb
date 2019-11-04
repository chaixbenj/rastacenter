class CreateVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :versions do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 250, :null => false
      t.column :versioning_date , :datetime
      t.timestamps
    end

    add_foreign_key :versions, :domaines
    
		add_index :versions, [:domaine_id, :name], name: "idx_versions_1"
  
  end
end
