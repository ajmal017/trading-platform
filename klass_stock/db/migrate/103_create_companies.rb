class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.integer :industry_id
      t.string :market
      t.string :symbol
      t.string :name
      t.string :name_th
      t.text :description
      t.text :description_th
      t.string :website
      t.date :established_at
    end
    add_index :companies, :industry_id
    add_index :companies, :market
    add_index :companies, :symbol
  end
end
