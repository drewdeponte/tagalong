module Tagalong
  module Owner
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def tagalong_owner
        puts "Woot owner"
      end
    end
  end
end
