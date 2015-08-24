class CreateTricks < ActiveRecord::Migration
  def self.up
    create_table :tricks do |t|
      t.integer :trickno
      t.integer :trickwinnerid
      t.integer :trickleadid
      t.integer :gameid
      t.integer :trickpoints
      t.string :tricksuit

      t.timestamps
    end
  end

  def self.down
    drop_table :tricks
  end
end
