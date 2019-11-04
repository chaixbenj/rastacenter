class CreateTestConstantes < ActiveRecord::Migration[5.1]
  def change
    create_table :test_constantes do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :project_id, :integer, :limit => 8, :null => false
      t.column :name, :string, :limit => 50, :null => false
      t.column :description, :string, :limit => 250, :null => true
      t.column :value, :string, :limit => 250, :null => true
      t.column :is_numeric, :integer, :limit => 1, :null => true
      t.column :is_boolean, :integer, :limit => 1, :null => true
      t.timestamps
    end
    
    add_foreign_key :test_constantes, :domaines
    add_foreign_key :test_constantes, :projects
    
    add_index :test_constantes, [:domaine_id, :project_id, :name], :name => 'idx_test_constantes_1'
  end
end
