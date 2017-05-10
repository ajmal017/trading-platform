class CreateSectors < ActiveRecord::Migration
  def change
    create_table :sectors do |t|
      t.string :name
      t.string :symbol
      t.string :name_th
    end
  end
end
