class CreateKanbans < ActiveRecord::Migration[5.1]
  def change
    create_table :kanbans do |t|
		t.column :domaine_id, :integer, :limit => 8, :null => false
		t.column :name, :string, :limit => 250, :null => false
		t.column :description, :text
		t.column :is_active, :integer, :limit => 1, :null => true
		t.column :private, :integer, :limit => 1, :null => true
		t.column :owner_user_id, :integer, :limit => 8, :null => true
		t.column :father_id, :integer, :limit => 8, :null => true
		t.timestamps
    end
    
    add_foreign_key :kanbans, :domaines
  end
end
