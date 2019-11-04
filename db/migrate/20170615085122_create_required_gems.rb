class CreateRequiredGems < ActiveRecord::Migration[5.1]
  def change
    create_table :required_gems do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :version_id, :integer, :limit => 8, :null => true
      t.column :gems, :text
	  t.column :current_id, :integer, :limit => 8
      t.timestamps
    end
    
    add_foreign_key :required_gems, :domaines
    add_foreign_key :required_gems, :versions
    
    add_index :required_gems, [:domaine_id, :version_id], name: "idx_required_gems_1"
    

  end
end
