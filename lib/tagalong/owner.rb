module Tagalong
  module Owner
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def tagalong_owner
        class_eval do
          has_many :tagalong_tags, :class_name => 'Tagalong::TagalongTag', :foreign_key => 'owner_id'
          include Tagalong::Owner::InstanceMethods
        end
      end
    end

    module InstanceMethods
      def list_tags_by_usage
        puts "would list tags by usage owned by #{self.inspect}"
      end
    end
  end
end
