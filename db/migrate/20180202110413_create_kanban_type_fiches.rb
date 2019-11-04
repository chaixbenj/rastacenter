class CreateKanbanTypeFiches < ActiveRecord::Migration[5.1]
  def change
    create_table :kanban_type_fiches do |t|
      t.column :domaine_id, :integer, :limit => 8, :null => false
      t.column :kanban_id, :integer, :limit => 8, :null => false
      t.column :type_fiche_id, :integer, :limit => 8, :null => false
      t.timestamps
    end
    
    add_foreign_key :kanban_type_fiches, :domaines
    add_foreign_key :kanban_type_fiches, :kanbans
    add_foreign_key :kanban_type_fiches, :type_fiches, column: :type_fiche_id, primary_key: :id


  end
end
