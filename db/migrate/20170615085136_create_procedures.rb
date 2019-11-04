class CreateProcedures < ActiveRecord::Migration[5.1]
  def change
    create_table :procedures do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :funcandscreen_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 250, :null => false
      t.column :description, :text
      t.column :parameters, :string, :limit => 1024, :null => true
	  t.column :return_values, :string, :limit => 1024, :null => true
      t.column :code, :text
      t.column :version_id, :integer, :limit => 8, :null => true
      t.column :is_used, :integer, :limit => 2, :null => false, :default => 0
	  t.column :current_id, :integer, :limit => 8
      t.timestamps
    end
    add_foreign_key :procedures, :domaines
    add_foreign_key :procedures, :funcandscreens
    add_foreign_key :procedures, :versions
    
    add_index :procedures, [:domaine_id, :version_id, :funcandscreen_id], :name => 'idx_procedures_1'
  end
end
