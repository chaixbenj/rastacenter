class CreateRefScreenshots < ActiveRecord::Migration[5.1]
  def change
    create_table :ref_screenshots do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 200, :null => false
      t.column :location, :string, :limit => 200, :null => false
      t.column :configstring, :text
      t.column :pngname, :string, :limit => 250, :null => true
      t.timestamps
    end
    
    add_foreign_key :ref_screenshots, :domaines
    
    add_index :ref_screenshots, [:domaine_id, :name, :location], name: "idx_ref_screenshots_1"
  end
end
