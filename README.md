# Tagalong

[![Build Status](https://secure.travis-ci.org/cyphactor/tagalong.png?branch=master)](http://travis-ci.org/cyphactor/tagalong)

[Tagalong](http://github.com/cyphactor/tagalong) is a Rails tagging plugin that is intended to be clean, efficient, and simple. I have tried hard to keep the API slim and intelligable in terms of Object Oriented Programming. I focused heavily on this as I feel most other Rails tagging plugins seriously neglect OO in their APIs.

The other key differentiation between [Tagalong](http://github.com/cyphactor/tagalong) and other tagging libraries is the relational database structure behind the scenes. This database structure allows [Tagalong](http://github.com/cyphactor/tagalong) to provide not only an Object Oriented API, but also a set of features that help differentiate it from other Rails tagging plugins.

## Feature Overview

* clean Object Oriented API
* does NOT require saving of the model when tagging/untagging
* keeps history of tags Taggers have used
* allows defining multiple Taggers and Taggables
* tracks the number of times tags are used
* returns tag lists in alphabetical order (imporant for UI)

## Installation

Add this line to your application's Gemfile:

    gem 'tagalong'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tagalong

## Usage

### Migration Setup

In order to use [Tagalong](http://github.com/cyphactor/tagalong) you have to generate the proper migrations so that the tags can be stored in the database. You can do this with the following command:

    rails generate tagalong:migration

The above will generate the migration and place it appropriately in the db/migrate/ project path so that the next time you `rake db:migrate` it will make the changes to the database.

### Declaring Taggers and Taggables

In addition to generating and running the migrations, you also need to declare at least one Tagger and at least one Taggable. This is done as follows:

    class Contact < ActiveRecord::Base
      tagalong_taggable
    end

    class User < ActiveRecord::Base
      tagalong_tagger
    end

Once you have declared at least one Tagger and at least one Taggable you can use them in your app in the numerous ways as outlined below.

### Tagging

To tag you must call the `tag` method on a Tagger object and hand it a persisted Taggable object with the given tag that you want to apply.

    @user.tag(@contact, "sometag")

### Untagging

To untag you must call the `untag` method on a Tagger object and hand it a persisted Taggable object with the given tag that you want to untag.

    @user.untag(@contact, "sometag")

### List tags

You can get the list of tags for either a Tagger or a Taggable.

When you get the tags from a Tagger you are getting a list of all tags that Tagger has ever used in ascending alphabetical order.

    @user.tags
    # => ['another_tag', 'some_tag', 'woot_tag']

When you get the tags from a Taggable you are getting a list of all the tags that Taggable is currently tagged with in ascending alphabetical order.

    @contact.tags
    # => ['some_tag', 'woot_tag']

### List tags with usage info

Passing a Taggable object to the tags method on the Tagger will return a list of hash objects containing the tag ( **:tag** ), a boolean representing if the taggable is currently tagged with that tag ( **:used** ), and the number of references of that tag by the Tagger ( **:number_of_references** ). The resulting list of hashes is ordered by tag in ascending alphabetical order.

    @user.tags(@contact)
    # => [
           { tag: 'another_tag', :used => false, :number_of_references => 42 },
           { tag: 'some_tag', :used => true, :number_of_references => 23 },
           { tag: 'woot_tag', :used => true, :number_of_references => 2 }
         ]

### List taggables that have a tag

You can acquire an array of Taggable objects that are tagged with a given tag using the `taggables_with` method on the Tagger object as follows:

    @user.taggables_with('some_tag')
    # => [Contact Object, Contact Object]

### Check if Taggable is tagged with a tag

You can determine if a Taggable is tagged with a given tag by using the `tagged_with?` method on the Taggable object as follows:

    @contact.tagged_with?('some_tag')
    # => true

The `tagged_with?` method returns `true` in the case that the Taggable is currently tagged with the given tag, and `false` in the case where the Taggable is NOT currently tagged with the given tag.

## Credits

I just wanted to thank all of the other open source Rails tagging plugins out there. Especially, acts-as-taggable-on, I learned a lot from you all. Thanks!

I also want to thank [RealPractice, Inc.](http://realpractice.com) for donating some developer hours to the project as well as being our initial user.

Beyond that I want to specifically thank [@cyoungberg](http://github.com/cyoungberg) and [@russCloak](http://github.com/russCloak) for discussing the API decissions with me. It definitely helped having you guys as a sounding board.

## Contributing

If you are interested in contributing code please follow the process below and please include tests. Also, please fill out issues if you have discovered a bug or simply want to request a feature on our GitHub [issues](http://github.com/cyphactor/tagalong/issues) page.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
