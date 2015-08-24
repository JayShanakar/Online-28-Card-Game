class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.string :suit
      t.string :cardno
      t.integer :points
      t.integer :playerid
      t.boolean :dealstatus
      t.boolean :playstatus

      t.timestamps
    end
  end

  def self.down
    drop_table :cards
  end
end
