class Contact < ActiveRecord::Base
  tagalong_taggable
end

class User < ActiveRecord::Base
  tagalong_owner
end
