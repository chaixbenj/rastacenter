class CreateRunStoreData < ActiveRecord::Migration[5.1]
  def change
    create_table :run_store_data do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :run_id, :integer, :limit => 8, :null => false
      t.column :key, :string, :limit => 120, :null => true
      t.column :value, :text, :null => true
      t.timestamps
    end
    
    add_foreign_key :run_store_data, :domaines
    add_foreign_key :run_store_data, :runs
    
    add_index :run_store_data, [:domaine_id, :run_id, :key], unique: true, :name => 'idx_run_store_data_1'
    
  end
end
