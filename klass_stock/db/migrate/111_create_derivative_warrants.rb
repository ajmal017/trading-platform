class CreateDerivativeWarrants < ActiveRecord::Migration
  def change
    create_table :derivative_warrants do |t|
      t.integer :company_id
      t.string :symbol
      t.string :dw_type
      t.string :issuer
      t.date :trading_date
      t.date :last_trading_date
      t.date :expiration_date
      t.boolean :active, :default => true
    end
    add_index :derivative_warrants, :company_id
    add_index :derivative_warrants, :symbol
    add_index :derivative_warrants, :dw_type
    add_index :derivative_warrants, :issuer
    add_index :derivative_warrants, :active
  end
end
