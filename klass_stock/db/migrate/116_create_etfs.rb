class CreateEtfs < ActiveRecord::Migration
  def change
    create_table :etfs do |t|
      t.string :symbol
      t.string :name
      t.boolean :active, :default => true
    end
    add_index :etfs, :symbol
    add_index :etfs, :active
  end
end
