class Contact < ActiveRecord::Base
  tagalong_taggable

  # has_tags('')

  # add_tag( needs owner )
  # add_tag("tag_name", owner)
  # remove_tag( nukes the association )
  # get_list_of_tags_ordered_by_usage
end

class User < ActiveRecord::Base
  tagalong_owner

  # get_list_of_tags_ordered_by_usage
end
