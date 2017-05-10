class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.integer :industry_id
      t.integer :company_id
      t.string :symbol
      t.string :market
      t.date :trading_date
      t.boolean :active, :default => true
    end
    add_index :stocks, :industry_id
    add_index :stocks, :company_id
    add_index :stocks, :symbol
    add_index :stocks, :market
    add_index :stocks, :active
  end
end
