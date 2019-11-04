class CreateDataSets < ActiveRecord::Migration[5.1]
  def change
    create_table :data_sets do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :version_id, :integer, :limit => 8, :null => true
      t.column :name, :string, :limit => 60, :null => false
      t.column :description, :text
	  t.column :current_id, :integer, :limit => 8
	  t.column :is_default, :integer, :limit => 1, :null => false
      t.timestamps
    end
    
    add_foreign_key :data_sets, :domaines
    add_foreign_key :data_sets, :versions
    
    add_index :data_sets, [:domaine_id, :version_id, :name], :name => 'idx_data_sets_1'

  end
end
