module Tagalong
  class TaggableNotPersisted < StandardError
  end
  class TagNotFound < StandardError
  end
  class TagAlreadyInUse < StandardError
  end
  class TagCannotBeBlank < StandardError
  end
end
