class CreateFractionTrades < ActiveRecord::Migration
  def change
    create_table :fraction_trades do |t|
      t.integer :portfolio_id, :default => 1
      t.string :symbol
      t.integer :volume, :default => 1000
      t.boolean :f1, :default => false
      t.boolean :f2, :default => false
      t.boolean :f3, :default => false
      t.boolean :f4, :default => false
      t.boolean :f5, :default => false
      t.boolean :f6, :default => false
      t.boolean :f7, :default => false
      t.boolean :f8, :default => false
      t.boolean :f9, :default => false
      t.boolean :f10, :default => false
      t.boolean :active, :default => true
    end
    add_index :fraction_trades, :portfolio_id
    add_index :fraction_trades, :symbol
    add_index :fraction_trades, :active
    add_index :fraction_trades, [:symbol, :active]
    add_index :fraction_trades, [:portfolio_id, :symbol, :active]
  end
end
