class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :portfolio_id
      t.string :symbol
      t.datetime :datetime
      t.float :price
      t.integer :volume
      t.string :side
      t.timestamps
    end
    add_index :orders, :portfolio_id
    add_index :orders, :symbol
    add_index :orders, :datetime
    add_index :orders, :created_at
    add_index :orders, [:portfolio_id, :symbol]
    add_index :orders, [:portfolio_id, :side]
    add_index :orders, [:portfolio_id, :symbol, :side]
  end
end
