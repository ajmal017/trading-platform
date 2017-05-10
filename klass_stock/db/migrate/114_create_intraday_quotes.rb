class CreateIntradayQuotes < ActiveRecord::Migration
  def change
    create_table :intraday_quotes do |t|
      t.datetime :datetime
      t.string :symbol
      t.float :last_price
      t.float :bid_price
      t.integer :bid_volume
      t.float :offer_price
      t.integer :offer_volume
    end
    add_index :intraday_quotes, :symbol
    add_index :intraday_quotes, [:symbol, :datetime]
  end
end
