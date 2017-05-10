class CreatePreOrders < ActiveRecord::Migration
  def change
    create_table :pre_orders do |t|
      t.string :symbol
      t.string :side
      t.integer :volume
      t.float :price
      t.boolean :active, default: true
    end
    add_index :pre_orders, :active
  end
end
