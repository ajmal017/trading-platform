class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.date :date
      t.string :symbol
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.decimal :volume
      t.decimal :value
      t.float :change
      t.float :percent_change
    end
    add_index :quotes, :date
    add_index :quotes, :symbol
    add_index :quotes, [:date, :symbol]
  end
end
