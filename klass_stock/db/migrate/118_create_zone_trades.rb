class CreateZoneTrades < ActiveRecord::Migration
  def change
    create_table :zone_trades do |t|
      t.integer :portfolio_id, default: 1
      t.string  :symbol
      t.integer :volume, default: 1000
      t.integer :zones, default: 5
      t.integer :available, default: 0
      t.float   :ref_buy, default: 0.0
      t.float   :ref_sell, default: 0.0
      t.boolean :active, default: true
    end
    add_index :zone_trades, :portfolio_id
    add_index :zone_trades, :symbol
    add_index :zone_trades, :active
    add_index :zone_trades, [:symbol, :active]
    add_index :zone_trades, [:portfolio_id, :symbol, :active]
  end
end
