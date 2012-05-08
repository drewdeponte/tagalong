module Tagalong
  module Taggable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def tagalong_taggable
        puts "Woot taggable"
      end
    end
  end
end
