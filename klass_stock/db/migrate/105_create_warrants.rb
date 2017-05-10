class CreateWarrants < ActiveRecord::Migration
  def change
    create_table :warrants do |t|
      t.integer :company_id
      t.string :symbol
      t.float :exercise_price
      t.string :exercise_ratio
      t.date :trading_date
      t.date :expiration_date
      t.boolean :active, :default => true
    end
    add_index :warrants, :company_id
    add_index :warrants, :symbol
    add_index :warrants, :active
  end
end
