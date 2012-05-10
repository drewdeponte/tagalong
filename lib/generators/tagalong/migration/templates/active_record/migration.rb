class TagalongMigration < ActiveRecord::Migration
  def self.up
    create_table :tagalong_tags do |t|
      t.string :name
      t.integer :number_of_references
      t.integer :tagger_id
      t.string :tagger_type

      t.timestamps
    end

    add_index :tagalong_tags, :tagger_id
    add_index :tagalong_tags, :tagger_type

    create_table :tagalong_taggings do |t|
      t.integer :tagalong_tag_id
      t.integer :taggable_id
      t.string :taggable_type

      t.timestamps
    end

    add_index :tagalong_taggings, :tagalong_tag_id
    add_index :tagalong_taggings, :taggable_id
    add_index :tagalong_taggings, :taggable_type
  end

  def self.down
    drop_table :tagalong_tags
    drop_table :tagalong_taggings
  end
end
