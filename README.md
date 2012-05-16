# Tagalong

[![Build Status](https://secure.travis-ci.org/cyphactor/tagalong.png?branch=master)](http://travis-ci.org/cyphactor/tagalong)

Tagalong is a Rails plugin that is intended to be clean, efficient, and simple. I have tried very hard to have the API make sense in terms of OOP as I have seen many other tagging libraries that I don't think do a great job of this.

The other key differentiation between Tagalong and many of the other tagging libraries out there is the relational database structure behind the scenes. This allows us to differentiate this tagging plugin in the following ways:

* clean object oriented API
* does NOT require saving of the model being tagged
* keeps history of tags Taggers have used
* allows defining multiple Taggers and Taggables
* tracks number of times tags are used

## Installation

Add this line to your application's Gemfile:

    gem 'tagalong'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tagalong

## Usage

### Migration Setup

In order to use `tagalong` you have to generate the proper migrations so that the tags can be stored in the database. You can do this with the following command:

    rails generate tagalong:migration

The above will generate the migration and place it appropriately in the db/migrate/ project path so that the next time you `rake db:migrate` it will make the changes to the database.

### Declaring Taggers and Taggables

In order to use `tagalong` you need to first declare at least one Tagger and at least one Taggable. You do this as follows:

    class Contact < ActiveRecord::Base
      tagalong_taggable
    end

    class User < ActiveRecord::Base
      tagalong_tagger
    end

### Tag things

To tag things you must use the Tagger object and hand it a persisted Taggable object with the given tag that you want to apply as follows:

    @user.tag(@contact, "sometag")

### Untag things

To untag things you must use the Tagger object and hand it a persisted Taggable object with the given tag that you want to untag as follows:

    @user.untag(@contact, "sometag")

### List tags

You can get the list of tags for either a Tagger or a Taggable.

When you get the tags from a Tagger you are getting a list of all tags that tagger has ever used. This can be done as follows:

    @user.tags
    # => ['some_tag', 'another_tag', 'woot_tag']

When you get the tags from a Taggable you are getting a list of all the tags that taggable currently has applied. This can be done as follows:

    @contact.tags
    # => ['some_tag', 'woot_tag']

Tags are returned ordered by how often the tags are used.

### List tags with usage info

Passing a taggable object to the tags method on the Tagger will return a list of hash objects containing the tag (`tag`), a boolean representing if the tag is applied to the passed taggable (`used`), and the number of applications of that tag by the Tagger (`number_of_references`).

    @user.tags(@contact)
    # => [
           { tag: 'some_tag', :used => true, :number_of_references => 23 },
           { tag: 'another_tag', :used => false, :number_of_references => 42 }
         ]

### List taggables that have a tag

You can acquire an array of taggable objects that have a given tag using the `taggables_with` method on the Tagger object as follows:

    @user.taggables_with('some_tag')
    # => [Taggable Object, Taggable Object] (in this case Taggable Objects would be Contacts)

## Credits

I just wanted to thank all of the other open source Rails tagging plugins out there. Especially, acts-as-taggable-on, I learned a lot from you all. Thanks!

## Contributing

If you are interested in contributing code please follow the process below and please include tests. Also, please fill out issues if you have discovered a bug or simply want to request a feature on our GitHub issues page.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
