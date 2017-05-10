class CreateVocabularies < ActiveRecord::Migration
  def change
    create_table :vocabularies do |t|
      t.string :code
      t.string :en
      t.string :th
    end
    add_index :vocabularies, :code
    add_index :vocabularies, :en
  end
end
