class AddIndicesToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :set50, :boolean
    add_column :stocks, :set100, :boolean
    add_column :stocks, :sethd, :boolean

    add_index :stocks, :set50
    add_index :stocks, :set100
    add_index :stocks, :sethd
  end
end
