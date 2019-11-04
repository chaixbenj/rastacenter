class CreateKanbanStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :kanban_statuses do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :kanban_id, :integer, :limit => 8, :null => false
      t.column :status_id, :integer, :limit => 8, :null => false
      t.column :status_name, :string, :limit => 50, :null => false
      t.column :status_order, :integer, :limit => 1, :null => false
      t.timestamps
    end
    
    add_foreign_key :kanban_statuses, :domaines
    add_foreign_key :kanban_statuses, :kanbans
    add_index :kanban_statuses, [:domaine_id, :kanban_id, :status_order], name: "idx_kanban_status_1"
  end
end
