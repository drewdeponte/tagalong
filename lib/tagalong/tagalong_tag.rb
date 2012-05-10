module Tagalong
  class TagalongTag < ::ActiveRecord::Base
    has_many :tagalong_taggings, :dependent => :destroy, :class_name => 'Tagalong::TagalongTagging'
    belongs_to :tagger, :polymorphic => true

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => [ :tagger_id, :tagger_type ]
  end
end
