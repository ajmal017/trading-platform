class CreatePortfolios < ActiveRecord::Migration
  def change
    create_table :portfolios do |t|
      t.integer :user_id
      t.string :name
      t.boolean :active, :default => true
      t.timestamps
    end
    add_index :portfolios, :user_id
    add_index :portfolios, [:user_id, :active]
  end
end
