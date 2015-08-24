class CreateMoves < ActiveRecord::Migration
  def self.up
    create_table :moves do |t|
      t.integer :trickid
      t.integer :gameid
      t.integer :playerid
      t.integer :moveno
      t.string :cardsuit
      t.string :cardno
      t.integer :cardpoints

      t.timestamps
    end
  end

  def self.down
    drop_table :moves
  end
end
