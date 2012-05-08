module Tagalong
  module Owner
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def tagalong_owner
        class_eval { include InstanceMethods }
      end
    end

    module InstanceMethods
      def list_tags_by_usage
        puts "would list tags by usage owned by #{self.inspect}"
      end
    end
  end
end
