module Tagalong
  class TagalongTag < ::ActiveRecord::Base
    has_many :tagalong_taggings, :dependent => :destroy, :class_name => 'Tagalong::TagalongTagging'
    belongs_to :owner, :polymorphic => true

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => [ :owner_id, :owner_type ]
  end
end
