# ProductionModels

Easily access your data in the production database from the console.

Ever wanted to take a peek in the production data while developing, or to
transfer data from one database to the other? With ProductionModels, you can
use the same classes to access both databases simultaneously.

## Installation

Add this line to your application's Gemfile:

    gem 'production_models'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install production_models

Once loaded, remember to load the class with:

    require 'production'

(that's right, just `production` and not `production_models`)

## Usage

There are two forms for accessing your production database:

1. Prepend `Production::` to your model's class and you're accessing the
production database (quicker but has caveats, see section below)

2. Use `Production.wrap(ModelClass)` to call `ModelClass` methods on the
production database (slower to type and execute, but safer)

You can specify any other connection defined in `config/database.yml` by
calling `Production.connection = :connection_name` or by passing a database
URI, just as you would with `ActiveRecord::Base.establish_connection` because,
well, that's what happens behind the scenes. By default, you're accessing the
database configured in the `production` section of the configuration file.

In addition you can sync tables between environments with

    Production.push_from_development(ModelClass, AnotherModelClass, YetAnotherModelClass)

and similarly with

    Production.pull_to_development(ModelClass, AnotherModelClass, YetAnotherModelClass)

**The destination tables will be truncated**, so please be super-duper careful
when you use these.


## Bugs / caveats

The namespace approach does some metaprogramming magic to do its dirty job,
which works fine if your models are in the main namespace (i.e. they live in
`app/models`), but can lead to unpredictable results if your models are
namespaced. In particular, if you have a situation where you have

    class SomeClass < ActiveRecord::Base
      class SomeOtherClass < ActiveRecord::Base
      end
    end

then `Production::SomeClass::SomeOtherClass` will **not** point to the
production database, but instead to the _development_ database! This happens
because Ruby resolves namespaces from left to right and I couldn't figure out a
way to trigger a `const_missing` on a constant that's actually there. In this
case, you'll have to use `Production.wrap(SomeClass::SomeOtherClass)` and
you'll get a class that will point to the right database.

If you have a solution for this, feel free to patch it on. ;-)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
