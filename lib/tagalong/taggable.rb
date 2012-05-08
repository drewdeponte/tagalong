module Tagalong
  module Taggable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def tagalong_taggable
        class_eval { include InstanceMethods }
      end
    end

    module InstanceMethods
      def add_tag(tag_name)
        puts "woot tag #{tag_name} would be added"
      end

      def remove_tag(tag_name)
        puts "woot tag #{tag_name} would be removed"
      end
    end
  end
end
