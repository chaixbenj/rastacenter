class CreateCycles < ActiveRecord::Migration[5.1]
  def change
    create_table :cycles do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false 
      t.column :name, :string, :limit => 250, :null => false 
      t.column :description, :text
      t.column :release_id, :integer, :limit => 8, :null => false 
      t.column :string1, :string, :limit => 100, :null => true 
      t.column :string2, :string, :limit => 100, :null => true 
      t.column :string3, :string, :limit => 100, :null => true 
      t.column :string4, :string, :limit => 100, :null => true 
      t.column :string5, :string, :limit => 100, :null => true 
      t.column :string6, :string, :limit => 100, :null => true 
      t.column :string7, :string, :limit => 100, :null => true 
      t.column :string8, :string, :limit => 100, :null => true 
      t.column :string9, :string, :limit => 100, :null => true 
      t.column :string10, :string, :limit => 100, :null => true 
      t.column :value1, :string, :limit => 100, :null => true 
      t.column :value2, :string, :limit => 100, :null => true 
      t.column :value3, :string, :limit => 100, :null => true 
      t.column :value4, :string, :limit => 100, :null => true 
      t.column :value5, :string, :limit => 100, :null => true 
      t.column :value6, :string, :limit => 100, :null => true 
      t.column :value7, :string, :limit => 100, :null => true 
      t.column :value8, :string, :limit => 100, :null => true 
      t.column :value9, :string, :limit => 100, :null => true 
      t.column :value10, :string, :limit => 100, :null => true 
      t.timestamps
    end
    add_foreign_key :cycles, :domaines
    add_foreign_key :cycles, :releases
    
    add_index :cycles, [:domaine_id, :release_id], :name => 'idx_cycles_1'
  end
end
