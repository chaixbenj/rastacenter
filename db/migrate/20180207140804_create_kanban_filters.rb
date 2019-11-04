class CreateKanbanFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :kanban_filters do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :kanban_id, :integer, :limit => 8, :null => false
      t.column :field_name, :string, :limit => 250, :null => false
      t.column :value_id, :integer, :limit => 8, :null => false
      t.column :value_name, :string, :limit => 50, :null => false
	  t.column :field_value, :string, :limit => 250, :null => true
      t.timestamps
    end
    
    add_foreign_key :kanban_filters, :domaines
    add_foreign_key :kanban_filters, :kanbans
    add_index :kanban_filters, [:domaine_id, :kanban_id], name: "idx_kanban_filters_1"
  end
end