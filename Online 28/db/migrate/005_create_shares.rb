class CreateShares < ActiveRecord::Migration
  def self.up
    create_table :shares do |t|
      t.integer :playerAid
      t.integer :playerBid
      t.integer :playerCid
      t.integer :playerDid

      t.timestamps
    end
  end

  def self.down
    drop_table :shares
  end
end
