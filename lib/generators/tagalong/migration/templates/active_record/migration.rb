class TagalongMigration < ActiveRecord::Migration
  def self.up
    create_table :tagalong_tags do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :tagalong_tags
  end
end
