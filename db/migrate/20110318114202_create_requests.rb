class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|

      t.string :title
      t.float :budget
      t.string :deadline
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end
