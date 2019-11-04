class CreateDomaines < ActiveRecord::Migration[5.1]
  def change
    create_table :domaines do |t|
      t.column :guid, :string, :limit => 40, :null => false
      t.timestamps
    end

    Domaine.create id: 0,
                   guid: '0000000-0000000-0000000-0000000'
    end
end
