class CreateMonitoredSecurities < ActiveRecord::Migration
  def change
    create_table :monitored_securities do |t|
      t.string :symbol
      t.date :last_trading_date
      t.boolean :s1, :default => false
      t.boolean :s2, :default => false
      t.boolean :s3, :default => false
      t.boolean :active, :default => true
    end
    add_index :monitored_securities, :symbol
    add_index :monitored_securities, :active
    add_index :monitored_securities, :s1
    add_index :monitored_securities, :s2
    add_index :monitored_securities, :s3
  end
end
