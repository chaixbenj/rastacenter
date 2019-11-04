class CreateTypeFiches < ActiveRecord::Migration[5.1]
  def change
    create_table :type_fiches do |t|
		t.column :domaine_id, :integer, :limit => 8, :null => false
		t.column :name, :string, :limit => 250, :null => false 
		t.column :jsondesc, :text
		t.column :is_system, :integer, :limit => 1, :null => false, :default => 0
		t.column :sheet_id, :integer, :limit => 8, :null => true
		t.column :color, :string, :limit => 7, :null => true
		t.column :is_gherkin, :integer, :limit => 1, :null => true
		t.timestamps
    end
    
    add_foreign_key :type_fiches, :domaines
	add_foreign_key :type_fiches, :sheets
    add_index :type_fiches, [:domaine_id, :name], unique: true, name: "idx_type_fiches_1"
  end
end
