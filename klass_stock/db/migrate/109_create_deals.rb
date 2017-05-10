class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.integer :portfolio_id
      t.string :symbol
      t.datetime :bought_at
      t.float :bought_price
      t.datetime :sold_at
      t.float :sold_price
      t.integer :volume
      t.float :realized_pl
      t.float :percent_pl
      t.timestamps
    end
    add_index :deals, :portfolio_id
    add_index :deals, :symbol
    add_index :deals, [:portfolio_id, :symbol]
    add_index :deals, [:portfolio_id, :created_at]
    add_index :deals, [:portfolio_id, :symbol, :created_at]
  end
end
