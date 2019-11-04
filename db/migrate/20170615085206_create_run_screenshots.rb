class CreateRunScreenshots < ActiveRecord::Migration[5.1]
  def change
    create_table :run_screenshots do |t|
      t.column :guid, :string, :limit => 250, :null => false
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :run_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 200, :null => false
      t.column :location, :string
      t.column :configstring, :text
      t.column :type_screenshot, :string
	  t.column :pngname, :string, :limit => 250, :null => true
	  t.column :prct_diff, :integer, :limit => 2, :null => true
	  t.column :has_diff, :integer, :limit => 1, :null => true
      t.timestamps
    end
    
	add_index :run_screenshots, [:domaine_id, :run_id, :guid, :type_screenshot], unique: true, name: "idx_run_screenshots_1"
	add_index :run_screenshots, [:domaine_id, :run_id, :guid, :has_diff], name: "idx_run_screenshots_2"
	add_foreign_key :run_screenshots, :domaines
	add_foreign_key :run_screenshots, :runs
  end
end
