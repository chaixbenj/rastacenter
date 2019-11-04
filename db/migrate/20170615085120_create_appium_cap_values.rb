class CreateAppiumCapValues < ActiveRecord::Migration[5.1]
  def change
    create_table :appium_cap_values do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :init_value_id, :integer, :limit => 8, :null => true
      t.column :appium_cap_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 50, :null => false
      t.column :description, :text
      t.column :value, :string, :limit => 255, :null => true
      t.column :is_numeric, :integer, :limit => 1, :null => true
      t.column :is_boolean, :integer, :limit => 1, :null => true
      t.timestamps
    end
    
    add_foreign_key :appium_cap_values, :domaines
    add_foreign_key :appium_cap_values, :appium_caps
    add_foreign_key :appium_cap_values, :appium_cap_values, column: :init_value_id, primary_key: :id
    
    add_index :appium_cap_values, [:domaine_id, :appium_cap_id, :init_value_id], :name => 'idx_appium_cap_values_1'


  end
end
