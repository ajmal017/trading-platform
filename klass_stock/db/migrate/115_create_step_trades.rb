class CreateStepTrades < ActiveRecord::Migration
  def change
    create_table :step_trades do |t|
      t.integer :portfolio_id, :default => 1
      t.string :symbol
      t.integer :volume, :default => 500
      t.integer :max_step, :default => 100
      t.integer :current_step, :default => 0
      t.float :ref_buy, :default => 0.0
      t.float :ref_sell, :default => 0.0
      t.boolean :active, :default => true
    end
    add_index :step_trades, :portfolio_id
    add_index :step_trades, :symbol
    add_index :step_trades, :active
    add_index :step_trades, [:symbol, :active]
    add_index :step_trades, [:portfolio_id, :symbol, :active]
  end
end
