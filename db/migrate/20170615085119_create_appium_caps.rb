class CreateAppiumCaps < ActiveRecord::Migration[5.1]
  def change
    create_table :appium_caps do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :version_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 60, :null => false
      t.column :description, :text
      t.column :current_id, :integer, :limit => 8
      t.timestamps
    end
    
    add_foreign_key :appium_caps, :domaines
    add_foreign_key :appium_caps, :versions
    
    add_index :appium_caps, [:domaine_id, :version_id, :name], :name => 'idx_appium_caps_1'

end
end
