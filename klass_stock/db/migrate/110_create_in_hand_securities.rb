class CreateInHandSecurities < ActiveRecord::Migration
  def change
    create_table :in_hand_securities do |t|
      t.integer :portfolio_id
      t.string :symbol
      t.integer :sum_volume, :default => 0
      t.float :sum_price, :default => 0.0
    end
    add_index :in_hand_securities, :portfolio_id
    add_index :in_hand_securities, :symbol
    add_index :in_hand_securities, [:portfolio_id, :symbol]
    add_index :in_hand_securities, [:portfolio_id, :sum_volume]
  end
end
