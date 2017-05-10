class CreateIndustries < ActiveRecord::Migration
  def change
    create_table :industries do |t|
      t.integer :sector_id
      t.string :name
      t.string :symbol
      t.string :name_th
    end
    add_index :industries, :sector_id
  end
end
