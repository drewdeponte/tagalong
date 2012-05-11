# Tagalong

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'tagalong'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tagalong

## Usage

### The setup

In order to use `tagalong` you need to first declare at least one Tagger and at least one Taggable. You do this as follows:

    class Contact < ActiveRecord::Base
      tagalong_taggable
    end

    class User < ActiveRecord::Base
      tagalong_tagger
    end

    @user = User.new
    @contact = Contact.new

### Tag things

To tag things you must use the Tagger object and hand it a Taggable object with the given tag that you want to apply as follows:

    @user.tag(@contact, "sometag")

### Untag things

To untag things you must use the Tagger object and hand it a Taggable object with the given tag that you want to untag as follows:

    @user.untag(@contact, "sometag")

### List tags (needs to be finished)

You can get the list of tags for either a Tagger or a Taggable.

When you get the tags from a Tagger you are getting a list of all tags that tagger has ever used. This can be done as follows:

    @user.tags
    # => ['some_tag', 'another_tag', 'woot_tag']

When you get the tags from a Taggable you are getting a list of all the tags that taggable currently has applied. This can be done as follows:

    @contact.tags
    # => ['some_tag', 'woot_tag']

### List tags with usage info about a taggable (needs to be finished)

Passing a taggable object to the tags method on the Tagger will return a list of hash objects containing the tag (`tag`), a boolean representing if the tag is applied to the passed taggable (`used`), and the number of applications of that tag by the Tagger (`number_of_references`).

    @user.tags(@contact)
    # => [
           { tag: 'some_tag', :used => true, :number_of_references => 23 },
           { tag: 'another_tag', :used => false, :number_of_references => 42 }
         ]


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
