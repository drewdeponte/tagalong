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

Or manually install it:

    $ gem install tagalong

## API Concepts

There are three major concepts that one should understand before reading the documentation for the API, the Tag, Tagger, and Taggable.

### Tag

A Tag in the [Tagalong](http://github.com/cyphactor/tagalong) API is represented by a string. Conceptually it is simply a textual label that is associated with a Taggable and a Tagger.

### Tagger

A Tagger is an object that will be performing the action of applying a tag to a Taggable. In most Rails apps this is the a User object.

### Taggable

A Taggable is an object that will be having the tags applied to it. In a Rails app this could be a Task object, Contact object, or any type of object that you want to be able to tag.

## Usage

### Migration Setup

In order to use [Tagalong](http://github.com/cyphactor/tagalong), generate the proper migrations so that the tags can be stored in the database. This can be done with the following command:

    rails generate tagalong:migration

The above will generate the migration and place it appropriately in the `db/migrate/` project path.

### Declaring Taggers and Taggables

It is necessary to declare at least one Tagger and Taggable in addition to generating and running the migrations. This is done as follows:

    class Contact < ActiveRecord::Base
      tagalong_taggable
    end

    class User < ActiveRecord::Base
      tagalong_tagger
    end

Once Taggers and Taggables are declared, they can be used in numerous ways as outlined below.

### Tagging

To tag, call the `tag` method on a Tagger object and hand it a persisted Taggable object with the given label that you want to apply.

    @user.tag(@contact, "sometag")

### Untagging

To untag, call the `untag` method on a Tagger object and hand it a persisted Taggable object with the given label that you want to untag.

    @user.untag(@contact, "sometag")

### Deleting

To delete a tag, call the `delete_tag` method on a Tagger object and hand it the label of the tag you want to delete. This will remove the tag from the Tagger, as well as all Taggables that might be using it.

    @user.delete_tag("sometag")

### List Tagger tags

To list Tagger tags, call the `tags` method on a Tagger object. This will return an array of all tags that Tagger has ever used in ascending alphabetical order.

    @user.tags
    # => ['another_tag', 'some_tag', 'woot_tag']

### List Tagger tags with more information

You can get a list of tags that belong to a Tagger along with some additional information by calling the `tags_including` method. The result will be a hash that always contains the key **:name** which is the name of the tag. There can be other keys added to the hash if you choose to pass the option for them to the method. A list of the params you can pass and their explanations are below:

##### :number_of_references => true

This only takes true as a value. When passed, it will add **:number_of_references** to the result hash. The value of **:number_of_references** is the number of times the tag is used by the Tagger.

    @user.tags_including(:number_of_references => true)
    # => [
           { name: 'another_tag', :number_of_references => 42 },
           { name: 'some_tag', :number_of_references => 23 },
           { name: 'woot_tag', :number_of_references => 2 }
         ]

##### :has_been_tagged => @contact

Takes a Taggable as a value. When passed, it will add **:has_been_tagged** to the result hash for each tag returned. The value of **:has_been_tagged** will contain a boolean representing if the Taggable passed is tagged by the current tag in the iteration.

    @user.tags_including(:has_been_tagged => @contact)
    # => [
           { name: 'another_tag', :has_been_tagged => true },
           { name: 'some_tag', :has_been_tagged => false },
           { name: 'woot_tag', :has_been_tagged => true }
         ]

### List Taggable tags

To list Taggable tags, call the `tags` method on a Taggable object. This will return an array of all tags that Taggable is currently tagged with in ascending alphabetical order.

    @contact.tags
    # => ['some_tag', 'woot_tag']

### List Taggables that have a tag

To list Taggables that have a tag, call the `taggables_with` method on a Tagger object as follows. This will return an array of Taggable objects that are currently tagged with the given tag.

    @user.taggables_with('some_tag')
    # => [Contact Object, Contact Object]

### Check if Taggable is tagged with a tag

To check if a Taggable is tagged with a tag, call the `tagged_with?` method on a Taggable object as follows. This will return `true` in the case that the Taggable IS currently tagged with the given tag, and `false` in the case where the Taggable is NOT currently tagged with the given tag.

    @contact.tagged_with?('some_tag')
    # => true

## Credits

I just wanted to thank all of the other open source Rails tagging plugins out there. Especially, [acts-as-taggable-on](http://github.com/mbleigh/acts-as-taggable-on), [is_taggable](http://github.com/jamesgolick/is_taggable), and [rocket_tag](http://github.com/bradphelan/rocket_tag). I learned a lot from you all.

I also want to thank [RealPractice, Inc.](http://realpractice.com) for donating some developer hours to the project as well as being our initial user.

Beyond that I want to specifically thank [@cyoungberg](http://github.com/cyoungberg) and [@russCloak](http://github.com/russCloak) for discussing the API decissions with me. It definitely helped having you guys as a sounding board.

## Contributing

If you are interested in contributing code please follow the process below and include tests. Also, please fill out issues on our GitHub [issues](http://github.com/cyphactor/tagalong/issues) page if you have discovered a bug or simply want to request a feature.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
